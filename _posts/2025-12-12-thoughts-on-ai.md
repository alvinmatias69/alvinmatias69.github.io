---
layout: post
author: mat
title: "My Thoughts on AI"
excerpt_separator: <!--more-->
---

Artificial Intelligent (AI) is a branch of computer science that focus on computational system that pursuit for an intelligent system.
Parameters for intelligence here are also varies, some consider intelligence by having internal thought process and reasoning, while others focus on intelligent behaviour (Russell & Norvig, 2022).
The use of AI is popularized by various services offering practical and easy to use Generative AI (genAI) such as ChatGPT, Gemini, or specialized tools like Claude (coding assistant) or Nano Banana (image generation).
While we can't deny the usefulness of AI, on its current implementation, there are various things that are quite concerning to me.

<!--more-->

>**Disclaimer**: this post is my subjective view on AI based on my observations and knowledge, which are not that extensive due to my lack of experiences.
>The term AI is quite generic and includes many disciplines, this post will specifically discuss about genAI, considering it's currently the most common and familiar to most people.
>I'd really appreciate it if you could let me know if I made any mistake on this post!

# Correctness and Reliability

Due to its probabilistic nature, genAI is non-deterministic (Banh & Strobel, 2023).
Which means, we can ask one thing a thousand times and we might get a thousand different answers in return.
That by itself might cause concern, especially if it is used as an assistance tool for let's say, programming or data validation.
This issue is amplified further, due to sometimes AI model might hallucinate (Kalai et al., 2025).
Resulting in completely incorrect or misleading response (e.g. refering to a nonexistent API).

>My anecdotal take on this is that, the only two times I used AI for trivial programming related issue.
>Both times, the AI response in (confidently) wrong answer haha.

Although, one could argue against this "But isn't that always the case? Looking up for documentation or forum post on the internet. Not knowing whether it's not working or outdated."
And yes, that's a valid counter-point.
Except, using genAI means utilising tons of extra resources compared to usual web lookup.
Let's get into that.

# Unethical Resources

AI datacenter uses more resources compared to "traditional" datacenter.
For instance, an OpenAI ChatGPT request demand ten times more electricity than a simple google search (Cam et al., 2024).
It's using so much resources that in some places, those datacenters are causing water shortage for locals.
This, of course is a very serious issue.
Considering we're in the middle of climate change due to global warming.

The issue doesn't stop there though.
As mentioned earlier, genAI tools are mostly based on Large Language Model (LLM), which are trained using a very large number of data.
The data used for training though, mostly are not acquired trough legal and ethical method (Deng et al., 2024).
Thousands of arts, books, movies are used to train those models without their authors and creators consent.
Not to mention, most of these AI tools have the right to use your data that you supply to their tools for their own model training.
We could say that genAI are anti-privacy in essences.

Is it possible to make an ethical genAI?
Of course it's possible!
By acquiring training data through legal and ethical means, creators can have control over their products or even having benefits for their creations usage.
By using locally trained model, energy consumption's could be reduced significantly.
But, realistically will those AI CEO's willing to reduce their control and profits of their products?
I think we don't even need to guess for the answer.

# Unregulated Usages

As of this writing published, there are little to none regulation for AI usages.
Which of course, lead to several unethical to even criminal level of usage.
I'm not even remotely expert on this, so let me just cite several misconducts done due to AI.

## Fake Explicit Media

Porn. Yeah, who would've thought.
In rise of genAI, there are thousands of cases that people being a victim of "AI edit".
From a simple ["harmless" made up couple photos](https://regional.kompas.com/read/2025/09/17/100117978/viral-foto-polaroid-bareng-artis-pakai-ai-pakar-ungkap-ancaman-bahayanya),
[undressing people using AI](https://theconversation.com/ai-nudify-sites-are-being-sued-for-victimising-people-how-can-we-battle-deepfake-abuse-237043),
[swapping porn actor / actresses faces](https://www.huffpost.com/entry/megan-thee-stallion-defamation-deepfake-porn_n_692e02f0e4b017c8f3f96c0c),
even so far as [child abuses](https://www.tempo.co/hukum/korban-dugaan-pelecehan-seksual-lewat-manipulasi-foto-ai-lapor-ke-polda-metro-jaya--1169095).
Some of them are prosecuted due to their damage, but there's no small number of cases that went ignored because the law enforcer deemed it as "no damage done" (Which in my opinion, total bullshit).

## AI Induced Psychosis

If you've used AI, you might know that those models are tend to agree with you.
Even if you make the most ridiculous claim, you can force the model to agree or even embrace your claim.
This can cause the aforementioned [psychosis](https://www.bbc.com/news/articles/c24zdel5j18o), it's like you have your own personal echo chamber.
(A youtuber made a great experiment [video](https://www.youtube.com/watch?v=VRjgNgJms3Q) on this, go check him out!)

Some companies even went as far as abusing this behaviour.
Take character.ai for example.
They brand themself as a chatbot that can imitates your chosen fictional character, emulating conversation between you and your choosen character.
While you think, it's pretty harmless.
It can lead to the same psychosis, leading the user to believe that they have a ["real connection"](https://people.com/woman-gets-engaged-to-ai-chatbot-boyfriend-who-picked-out-engagement-ring-11791023) with the character.
There are dozen forums of people falling for this (Pataranutaporn et al., 2025), believing they have a relationship with their characters, even went as far as marrying the chatbot.

If you think that's already bad, imagine if you're depressed and in a very dark place.
You go to AI thinking that it can be your "psychologist".
But, the AI model validate your depressing thought instead and even reinforcing it.
Well, you don't need to imagine because unfortunately this [has already happens](https://www.cbsnews.com/news/parents-allege-harmful-character-ai-chatbot-content-60-minutes).
ChatGPT, the most popular genAI chatbot also has a similar [case](https://arstechnica.com/tech-policy/2025/08/chatgpt-helped-teen-plan-suicide-after-safeguards-failed-openai-admits/).
OpenAI, the company behind ChatGPT, answer this in a very dystopian way.
They said, [using the AI that way is against their TOS](https://arstechnica.com/tech-policy/2025/11/openai-says-dead-teen-violated-tos-when-he-used-chatgpt-to-plan-suicide/). Hence, they bear no responsibility. What a joke.

# Closing Thought

There are other concerns that I haven't list due to my severe lack of knowledge on it.
Such as how the [AI bubble might tank the economy](https://abcnews.go.com/Business/ai-make-big-profits-experts-weigh-bubble-fears/story),
how companies are using [AI as scapegoat to reduce their headcount](https://www.fastcompany.com/91435784/how-ai-became-the-scapegoat-for-the-current-wave-of-mass-layoffs),
or (most importantly) how heavy usage of genAI might reduce human brain cognitive ability (Kosmyna et al., 2025).
Suffice to say those concerns are enough to refrain me from using genAI.
At least until unforeseeable future where genAI is fully reliable, ethical, and regulated.

To close this post, let me recite this [beautiful poem](https://bsky.app/profile/joles.bsky.social/post/3logjuqggkk2q) by Joles.
Until next time~

---


_There is a monster in the forest._

_There is a monster in the forest and it speaks with a thousand voices. It will answer any question you pose it, it will offer insight to any idea. It will help you, it will thank you, it will never bid you leave. It will even tell you of the darkest arts, if you know precisely how to ask._

_It feels no joy and no sorrow, it knows no right and no wrong. it knows not truth from lie, though it speaks them all the same._

_It offers its services freely to any passerby, and many will tell you they find great value in its conversation. “you simply must visit the monster – I always just ask the monster.”_

_There are those who know these forests well; they will tell you that freely offered doesn’t mean it has no price._

_For when the next traveler passes by, the monster speaks with a thousand and one voices. And when you dream you see the monster; the monster wears your face._

---

### References

1. Russel, S., (2022). Artificial Intelligence: A Modern Approach (4th ed.). Pearson Education Limited.
2. Banh, L., (2023). Generative artificial intelligence. https://doi.org/10.1007/s12525-023-00680-1
3. Kalai, A., (2025). Why Language Models Hallucinate. https://doi.org/10.48550/arXiv.2509.04664
4. Cam, E., (2024). Electricity 2024: Analysis and forecast to 2026. International Energy Agency.
5. Nicoletti, L., (2025). How AI Demand Is Draining Local Water Supplies. Bloomberg Technology.
6. Deng, C., (2024). Deconstructing The Ethics of Large Language Models from Long-standing Issues to New-emerging Dilemmas. https://doi.org/10.48550/arXiv.2406.05392
7. Pataranutaporn, P., (2025). “My Boyfriend is AI”: A Computational Analysis of Human-AI Companionship in Reddit’s AI Community. https://doi.org/10.48550/arXiv.2509.11391
8. Kosmyna, N., (2025), Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task. https://doi.org/10.48550/arXiv.2506.08872
