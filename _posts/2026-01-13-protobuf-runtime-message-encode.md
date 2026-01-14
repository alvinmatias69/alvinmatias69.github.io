---
layout: post
author: mat
title: "Create Protobuf Message Without Compiled Generated Code"
excerpt_separator: <!--more-->
---

Protocol Buffers (protobuf) are a language-neutral, platform-neutral extensible mechanism for serializing structured data.
It's the primary message format for gRPC, usually serialized and deserialized through native generated code.
While using generated code is favourable for production software due to its fast and easy message parsing, there's also a time where we might not unable to use generated code.
For example, development tools like Postman.
In this post, we will explore the possibility of parsing protobuf message without generated code.

<!--more-->

Protobuf message is binary serialized, hence it's almost impossible to create the message by hand, unlike json.
Fortunately, `protoc` (protobuf compiler) provide helper to encode and decode message from and to binary format from its text format.

```sh
# encode payload from STDIN and put the result in STDOUT
$ protoc --encode=<package.messageName> <protoFile>

# decode payload from STDIN and put the result in STDOUT
$ protoc --decode=<package.messageName> <protoFile>
```

For example, suppose we have this proto file:

```proto
// helloworld.proto
syntax = "proto3";

package helloworld;

...

message HelloRequest {
  string name = 1;
}

...
```

And this `HelloRequest` message in text format.
```
name: "This is example payload"
```

We can then encode the binary message accordingly.

```sh
$ protoc < text_payload --encode=helloworld.HelloRequest helloworld.proto > encoded_payload
```

Conversely, we can decode it back to text format.

```sh
$ protoc < encoded_payload --decode=helloworld.HelloRequest helloworld.proto > text_payload
```

> Reader might be wondering what is this text format.
> It's a format used to represent protobuf data in plain text, usually used for test or configuration.
> Reader can check its [documentation](https://protobuf.dev/reference/protobuf/textformat-spec/) for more informations.

Knowing this, we can utilize this to encode/decode protobuf message programatically without generated code.

# Implementation

On my previous [post](https://blog.matiasalvin.dev/posts/curl-grpc), we created a simple application to send gRPC request using libcurl.
Let's improve it so the project doesn't need the generated code to encode proto message.

> Reader can check the complete changes on the project [repo](https://github.com/alvinmatias69/curl_grpc/tree/protoc_encoding)

```c
char command[255];
sprintf(command, "protoc --encode=helloworld.HelloRequest %s > encoded_payload", argv[1]); // the protofile is passed through the first argument
FILE *encode_pipe = popen(command, "w");
fputs(argv[2], encode_pipe); // the text format request payload is passed through the second argument
```

First, instead of relying to generated code to encode the message, we use `popen` create a pipe that execute the protoc command.

```c
struct stat st;
stat("encoded_payload", &st);
size_t len = st.st_size;
uint8_t *buf;
buf = malloc(PREFIX_LENGTH + len);
buf[0] = 0;
... // code to generate prefix payload
FILE *encoded_payload =fopen("encoded_payload", "rb");
fread(buf+PREFIX_LENGTH, len,1, encoded_payload);
```

Then, we read the encoded payload and put it to our payload buffer.

```c
curl_global_init(CURL_GLOBAL_ALL);
CURL *curl = curl_easy_init();
...
curl_easy_setopt(curl, CURLOPT_POSTFIELDS, buf);
curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, len + PREFIX_LENGTH);
curl_easy_setopt(curl, CURLOPT_WRITEDATA, argv[1]);
```

The rest is still the same, send the payload using libcurl.

```c
size_t handle_callback(char *ptr, size_t size, size_t nmemb, void *userdata) {
  char command[255];
  sprintf(command, "protoc --decode=helloworld.HelloReply %s > response_decoded", (char *) userdata);
  FILE *decode_pipe = popen(command, "w");
  fputs(ptr+PREFIX_LENGTH, decode_pipe);
  pclose(decode_pipe);

  return size * nmemb;
}
```

Conversely, we can use the same trick to decode the response.
Now, we can test whether our application works.

```sh
$ ./curl_grpc helloworld.proto "name: \"inline payload\""
$ cat response_decoded
# msg: "Hello inline payload"
```

It works! With a simple change, we can remove dependency to generated code.
Although, there are few concerns regarding this approach.
- Payload needs to be in protobuf text format, which is not widely known (and might not be standard).
- Due to `popen` unidirectional nature, we need to have temporary file to store either the input or output. (there's a `popen2` implementation that address this exact concern, but that's non-standard AFAIK)
- Performance and utilization also might not be optimal, considering we need to fork and executing shell everytime.

Fortunately, because the `protoc` support the on the fly encoding and its [library](https://github.com/protocolbuffers/protobuf) is also open source.
We can take a peek at the code and use it directly.

> The bad news is, the library is written using c++.
> The last time I write c++ was more than ten years ago, in college data structure class.
> Hence, the code might be more slop than the usual.
> For that, I'm really sorry `m(_ _)m`

# (Kinda) Proper Implementation

> Reader can check the complete changes on the project [repo](https://github.com/alvinmatias69/curl_grpc/tree/protobuf_cpp)

First, we need to modify our `meson.build` system to change the project language to c++
```
project('curl_grpc', 'cpp',
  version : '0.1',
  default_options : ['warning_level=3'])

cc = meson.get_compiler('cpp')
...
sources = ['curl_grpc.cc']
```

Also, add additional libraries for protobuf encoding.

```
protobuf = dependency('protobuf',
    version : '>= 2.6.0',
    native : true)

libprotoc = cc.find_library('protoc',
    dirs : protobuf.get_pkgconfig_variable('libdir'))

deps = [
    dependency('libcurl', version: '>=7.50.0'),
    m_dep,
    protobuf,
    libprotoc,
    ]
```

Then we can use the library in our code.
```c
#include <google/protobuf/util/json_util.h>
  ...
  std::string payload;
  google::protobuf::util::Status status = google::protobuf::util::JsonToBinaryString(type_resolver, "type.googleapis.com/helloworld.HelloRequest", argv[2], &payload);
  if (!status.ok()) {
    std::cout << "fail to parse json to proto message\n";
    return 1;
  }

  size_t len = payload.length();
  std::vector<uint8_t> buf = {0, 0, 0, 0, 0};
  buf.insert(buf.end(), payload.begin(), payload.end());
  ...
```

For this, we utilize [json_util.h](https://protobuf.dev/reference/cpp/api-docs/google.protobuf.util.json_util/) a library header that provide functions to parse json to protobuf binary message and vice-versa.
Exactly what we need.

But first, we need to create the [type resolver](https://protobuf.dev/reference/cpp/api-docs/google.protobuf.util.type_resolver/) so the json parser can understand our data better.
```c
#include <google/protobuf/util/type_resolver.h>
#include <google/protobuf/util/type_resolver_util.h>

  ...
  google::protobuf::util::TypeResolver *type_resolver = google::protobuf::util::NewTypeResolverForDescriptorPool("type.googleapis.com", fd->pool());
  ...
```

And we need to provide [descriptor pool](https://protobuf.dev/reference/cpp/api-docs/google.protobuf.descriptor/#DescriptorPool) for the type resolver.
```c
#include <google/protobuf/compiler/importer.h>

  ...
  google::protobuf::compiler::MultiFileErrorCollector *error_collector = new SimpleErrorCollector();
  google::protobuf::compiler::DiskSourceTree *source_tree = new google::protobuf::compiler::DiskSourceTree();
  source_tree->MapPath("", ".");

  google::protobuf::compiler::Importer *importer = new google::protobuf::compiler::Importer(source_tree, error_collector);
  const google::protobuf::FileDescriptor *fd = importer->Import(argv[1]);
  ...
```

Basically, the descriptor pool is a pool of descriptor data derived from a proto file.
We use the [importer](https://protobuf.dev/reference/cpp/api-docs/google.protobuf.compiler.importer/) for this, so the library will resolve any import needed for given proto file.

Also, we need to create an implementation for the [error collector](https://protobuf.dev/reference/cpp/api-docs/google.protobuf.compiler.importer/#MultiFileErrorCollector).
For now, a simple printing should be sufficient.
```c
class SimpleErrorCollector : public google::protobuf::compiler::MultiFileErrorCollector {
public:
  void AddError(const std::string & filename, int line, int column, const std::string & message) override {
    std::cout << "error processing " << filename << " on line: " << line << " column: " << column << " message: " << message << "\n";
  }

  void AddWarning(const std::string & filename, int line, int column, const std::string & message) override {
    std::cout << "warning processing " << filename << " on line: " << line << " column: " << column << " message: " << message << "\n";
  }
};
```

Similarly, we can use the library to decode the binary message to json as well.
```c
size_t handle_callback(char *ptr, size_t size, size_t nmemb, void *userdata) {
  std::string payload_json;
  google::protobuf::util::TypeResolver *type_resolver = google::protobuf::util::NewTypeResolverForDescriptorPool("type.googleapis.com", (google::protobuf::DescriptorPool *) userdata);
  google::protobuf::util::Status status_second = google::protobuf::util::BinaryToJsonString(type_resolver, "type.googleapis.com/helloworld.HelloReply", ptr+PREFIX_LENGTH, &payload_json);

  if (!status_second.ok())
    std::cout << "fail to parse message to json\n";
  else
    std::cout << "response: " << payload_json << "\n";

  return size * nmemb;
}
```

Notice that we're not recreating the descriptor pool.
This is due to the pool is passed to the callback.
```c
  ...
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, fd->pool());
  ...
```
This way, we don't need to rebuild the descriptor pool over for a same protofile.

And that's it, we can now test it.
```sh
$ ./curl_grpc helloworld.proto "{\"name\": \"hello json\"}"
# response: {"msg":"Hello hello json"}
```

The request and response is now in string json format.
And we don't need to fork a new shell process each time we encode / decode protobuf message.
Neat!

# Closing Thought

This (and the previous) concepts are born from my idea to create a lightweight postman-like grpc tools.
While this proof of concept works, there are things that I need to clear before I can put it on a production application.

Due to my unfamiliarity with cpp, I think it's better to contain the cpp code in a shared library and expose C functions from them.
Even then, I still need to learn much more about cpp so I can make more optimized library than this slop.
Also, I need to iron out details on the application, such as supporting stream message and more complicated proto import.

The production grade application might be still far in the future.
But this is a great stepping stone, a solution that I've been looking for some times.
So then, until next time!
