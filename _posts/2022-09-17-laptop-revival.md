---
layout: post
author: mat
title: "Reviving My Old Laptop"
excerpt_separator: <!--more-->
---

Nowadays, most people will choose to buy a new electronic device rather than fix their broken device. Most devices are difficult to fix and it's not cheap either. Hence, most people might feel like it's not worth fixing it. So, why do I choose to fix mine?

<!--more-->

# Background

The laptop in question is the first gadget that I bought with my own salary. It's a MacBook Air from early 2015, I bought it back in college in 2017. I'm still a poor college student saving from my part-time jobs back then. For context, nowadays I mainly daily drive my desktop PC and use a company-issued laptop for work. So I'm in no dire need of a laptop, rather it's more of the sentimental value of the laptop itself.

Also, I've encountered some blog posts about how Linus Torvalds is currently using an M2 MacBook with Fedora installed. So, I thought hey if the latest MacBook can run Linux then maybe my old laptop will have no problem. It should be a fun project to do at the weekend!

## Problems

Just as I stated, the laptop is old and kinda unusable in its current state.

### Battery

Most problems of old electronic lies in the battery. At the time, my laptop can only hold for about 10 minutes on battery. So if I want to use it, I need to connect to a wall plug all the time. 

### Storage

My laptop only has 128Gb of storage. A "vanilla" macOS Big Sur installation takes about 40-50Gb of storage. Assume that additional basic software takes about 10Gb, it only leaves me with ~60Gb of storage. Not exactly that much by today's standard.

### System Overall

At the time of this writing, macOS Big Sur is released two years [ago](https://en.wikipedia.org/wiki/MacOS_Big_Sur) on 12 November 2020. While it still receives updates to this day, if someday Tim Apple decides to drop support for it my laptop is as good as a paperweight. Not to mention the performance is not the best. It's kinda usable, but I'm not a fan of a laggy machine.

# It's Revivin' Time!

After making sure that there are no important data saved (my brother was using my laptop for college for a while). I decided to fix the hardware issue first, the battery.

## A New Battery

Thankfully, the old gen MacBook is relatively easy to fix. A quick read at the iFixit [website](https://www.ifixit.com/Device/MacBook_Air_13%22_Early_2015) and unsurprisingly the step is quite a simple DIY project. Unfortunately, looking for the replacement battery itself is not quite easy. 

Because of the age of the laptop, looking for the original apple battery is out of the question (not to mention I don't think they sell spare parts at all). My only choice is to look for an [OEM](https://en.wikipedia.org/wiki/Original_equipment_manufacturer) battery from my local marketplace. Luckily for me, some online stores specialise in selling OEM laptop spare parts. After some days, the battery is arrived and ready.

The replacement itself is quite easy. It takes me about 15 minutes just by following instructions on the iFixit website. One thing to note though, apple (for whatever reason) doesn't use your standard Phillips head screw. So you need a specialise screw to disassemble the laptop, fortunately, my replacement battery comes with the appropriate screwdriver, all good for me!

What I don't expect is that battery calibration takes some time. It takes me about two days to complete 2 cycles of battery, so take this into the consideration.

## The Linux Strike Back

I decided to go with [SpiralLinux](https://spirallinux.github.io/) for the new OS. It's a Linux distro based on Debian with some basic configurations and some non-free software and drivers. Truthfully, I'd like to go for Ubuntu if they don't force snaps on their user. As for fedora, while I like the overall of it, it's too cutting edge for my taste.

What surprised me is that the installation process itself is not that different from your everyday machine. After attaching the USB installation, I turn on my laptop while holding the `Option` key (this is how you choose the boot option on a mac) and then enter the live demo of SpiralLinux. After making sure that everything but the webcam (more on this later) works, I proceed with the installation.

Because I'm not planning to use the macOS anymore, I wipe the whole storage. Hence, the installation process is as simple as clicking next and filling out forms. When the installation is complete, I reboot my laptop and take out the installation USB. When the machine is up, I'm greeted by your standard lightDM login screen. The installation is a success! Surely, there won't be any problem after this.

## Return of the Problems

Yeah, it'd be too naive to expect that there won't be any problems. Most blogs that I read said that most likely I'll encounter an issue with wireless connection. But, I'm able to connect to my home wifi easily. Both on the live USB and after the installation. I think the recent kernel has included the mac wifi driver in it.

### Touchpad Not Working

While on the live demo, I'm able to use the touchpad just fine. But, it's not working (and not detected even) after the installation. Using an external mouse works just fine though. I suspect that somehow the driver for it is either not installed or configured incorrectly. Thankfully, updating (`apt update && apt upgrade`) and restarting fixes the issue.

### Webcam Not Working

I've mentioned it before, the webcam is not working at all. This is due to the webcam used by mac doesn't use your daily standard driver (yeah, no surprise there). Thankfully, I stumbled upon the [facetimehd](https://github.com/patjak/facetimehd/) repository by patjak. The repository contains an experimental driver for the MacBook webcam. The [installation](https://github.com/patjak/facetimehd/wiki/Installation) process is quite straightforward, it works wonderfully. Besides known issues, I've not encountered any other problems.

### Keyboard Layout

It's not a problem per se, but rather a quality of life improvement. As we all know, apple (in their infinite wisdom and apple-centred design™) is using their own keyboard layout which is quite different from the standard keyboard layout. Thankfully (again), a user with the username free5lot has made a [repository](https://github.com/free5lot/hid-apple-patched) for solving this "issue". Goodbye apple-centred design™ layout, welcome sensible standard keyboard layout.

## The Config Menace

All problems are fixed, it's time to configure the machine. Now, I'm the kind of guy that has different VM for different occasions. Be it work or personal projects. Hence, I have a pretty complete (for me personally) ansible playbook to be based on. So, configuring is as simple as `$ ansible-pull -U <my_ansible_playbook_repo>` for me. Then again, you might be too naive if you think that everything will work without any problems.

### The Problem with Stable

Debian is stable, which means the available software might be months or even years behind the latest version. Most of the time this is not a problem, but rather an advantage. Because it'll provide much more stability and fewer unknown issues. But, I forgot that my current project is using [GTK4](https://docs.gtk.org/gtk4/index.html) which can be considered a new software and not available on Debian stable.

At this point, I have two options. One, compiling from source. This option is not exactly easy, as I need to compile the dependencies too. Also, gtk4 requires a recent version of Glibc. Which is not quite an easy feat to upgrade from the source. So I go with my second option, using the testing repository.

Debian has three different [repositories](https://www.debian.org/doc/manuals/debian-faq/choosing.en.html). The tl;dr is that new packages are first introduced to `unstable`. After some compiling and testing, it will move to `testing`. Finally, if all goes well, it will be moved to `stable`. Gtk4 is available on both testing and unstable repositories. 

While it's possible to wait until the package is introduced to stable, it'll take a while. So, I should change the repository. Thankfully, SpiralLinux provides an out-of-the-box way to change [repository](https://github.com/SpiralLinux/SpiralLinux-project/wiki#switching-from-debian-stable-to-the-testing-or-unstable-branch). Though, it'll take some times to migrate the repository. After it's done I can install my required packages and finally, my machine is ready to use!

# Afterword

![My MacBook Linux Desktop](/assets/images/laptop-revival/macbook_linux.png){: width="100%"}

Now, the storage usage is only about 14Gb, even after installing all of my additional software. The machine is also more snappy and doesn't turn off without plugging into power. Even though the journey is not exactly smooth, I'm quite happy with the result. Not only the laptop is usable again, but I also learn so much while configuring it. 

Well, I'm not exactly solved all of the problems. As currently, I'm not sure how to dispose of the old battery. I've found `octopus`, an Indonesian-based startup that handles e-waste. But, I haven't tried it yet. Maybe I'll make a review after trying it. In the meantime, please let me know if you have any information on e-waste disposal in Indonesia. See you in another post!
