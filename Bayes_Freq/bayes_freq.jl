### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 01591408-819d-11eb-3f81-73b53fa7e515
using PlutoUI

# ╔═╡ 8b6ff28c-818a-11eb-2421-41fa4a9aeedd
md"# Frequentist vs Bayesian inference
Dr Benjamin T. Vincent

NOTE: This session is an amalgamation of 2 previous lectures that have looked at [Hypothesis Testing](https://github.com/drbenvincent/PY52007-guest-lectures/blob/2021/Hypothesis%20testing/Hypothesis%20Testing.ipynb) in detail, and [Bayesian inference](https://github.com/drbenvincent/PY52007-guest-lectures/blob/2021/Bayesian%20inference/Bayesian_Inference_Part1.ipynb) in detail. This session is an attempt to combine these topics. So this session is not simply a combination of those previous sessions, we cover different examples and have different emphases. So it may be that in working through this material in your own time, going back to refer to these other sessions could be very useful as they go into more depth in certain places.
"

# ╔═╡ de82e978-818c-11eb-11bf-ffa1249a932a
md"
## The goal of this session
This session is going to give an introduction to Bayesian statistics. We will start with a motivating example, using one of the built in datasets included in JASP, and highlight the differences in the outputs.

### Frequentist output
This is the kind of output you get from JASP when running a traditional Frequentist independent samples T-Test. We can see that we get a few values:
- t: this is the t-statistic value
- df: is the degrees of freedom
- p: is the p-value, indicating the level of statistical significance
- Cohen's d: this is the effect size, which gives us an indication of how meaningful the differences are between groups.
![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/2021/Bayes_Freq/img/results_freq.png)

### Bayesian output
This figure below shows the kind of output you get from a Bayesian version of the same statistical test in JASP. The key result here is what is known as a Bayes Factor, $BF_{10}=2.217$. But we also get a nice graphical output. At the moment this might look all very mysterious, but by the end of this session you should understand it 🙂
![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/2021/Bayes_Freq/img/results_bayesian.png)

### The focus of this session
Having seen this motivating example and had a brief look at the differences in the outputs of a Frequentist and Bayesian output, our focus will be digging into the differences of the Frequentist and the Bayesian approaches.
"


# ╔═╡ aa32c604-818f-11eb-0fac-c9794460f86e
md"
# Part I: Conceptual differences

## The Frequentist approach
Under the Frequentist approach, the hypothesis (or state of the world) is assumed to be fixed. The data you collect from your experiment is assumed to be stochastic. That is, a mere instance of one possible dataset that you could have observed. You can imagine theoretically running the same experiment many many times, and each time you would observe slightly different data.

![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/f83a2a113af0f1258753e449a3e47276e4f8759c/Bayesian%20inference/img/fig3.PNG)

### The data generating process
The downward arrow in this diagram symbolicalises what we know about what processes occured that led to our dataset - we can call this the data generating process. For the moment we will keep this somewhat vauge until we look at a concrete example below. Having said that, it is not a difficult idea. It could be as simple as saying: _I believe the data from group 1 and group 2 are both normally distributed around zero_.

### Making claims about the data with the likelihood
We are able to do this, we can simulate what we would expect to see _if_ the null hypothesis is true. You can imagine that this would give us slightly different datasets, and thus slightly different t-statistic values. This basically describes what we would expect to see given the null hypothesis is true. This is what is known as the likelihood, $P( \mathrm{data} | \mathrm{H_0})$.

What is the likelihood? The most important thing you need to know about the likelihood is that it is a claim about the likelihood of observing some particular data according to the particular hypothesis under consideration, in this case $H_0$. This is both a good thing and a bad thing. 

The likelihood is very useful in telling us how likely it is that we would have observed something (like a t-statistic) under the null hypothesis. 
- If $P( \mathrm{data} | \mathrm{H_0})$ is a very low number, then we know that the data is not very consistent with $H_0$
- If $P( \mathrm{data} | \mathrm{H_0})$ is a high number, then we know that the data is pretty consistent with $H_0$.

You can see that this is useful. Frequentists use this in order to make claims about how likely or unlikey the data is under the null hypothesis. If the data is sufficiently unlikely to have been observed under $H_0$, then we could try to make a claim (a statistical inference) about the data.

### Questions
But there are some questions that spring to mind here:
- What does 'sufficiently unlikely' mean? How unlikely should the data be under $H_0$ for us to make a claim?
- What kind of claim can we really make? Can we make claims about our hypothesis, or just about the data?
"


# ╔═╡ d15e3ade-8193-11eb-2035-4bbf81b664c1
md"## Why are claims about the data unsatisfactory?
- Why isn't this good enough? 
- Why do we have to bother about the Bayesian approach? 
- Isn't it sufficient to observe data that are very improbable under $H_0$ and make scientific claims based on this?
"

# ╔═╡ edc51308-8190-11eb-1045-11be03efce84
md"
## The Bayesian approach

The Bayesian approach builds upon what we have looked at before, namely the data generating process. However, Bayesians want to make claims about how credible hypotheses are given the data $P( \mathrm{hypothesis} | \mathrm{data})$. This is known as the **posterior**, and in some ways it is the opposite of the likelihood.

![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/f83a2a113af0f1258753e449a3e47276e4f8759c/Bayesian%20inference/img/fig4.PNG)

### Understanding how the likelihood and prior are different
In a way, it is clear that:
- the likelihood, $P( \mathrm{data} | \mathrm{hypothesis})$ and $P( \mathrm{hypothesis} | \mathrm{data})$, is about how consistent a set of data are with a given hypothesis and that
- the posterior, $P( \mathrm{hypothesis} | \mathrm{data})$, is about how consistent a hypothesis is with some data. 

But it is good to dig into this. A great example can be found in Understanding Psychology as a Science by Zoltan Dienes. We can consider the probability that someone will have died within 2 years, given they have had their head bitten off by a shark. It is not often we can be 100% sure of something, but this is a good example where we would be extremely confident:

$P(\text{dead within 2 years} | \text{head bitten off by shark}) = 1$

But now we could consider the inverse of this... 

**Question:** What is the probability that someone who died within the last few years had their head bitten off by a shark? Roughly.
"

# ╔═╡ 246aef2c-819b-11eb-2aa0-d7d5b1834e3c
md"So this is a good demonstration that just because we know $P(\text{data}|\text{hypothesis})$, that really doesn't tell us about $P(\text{hypothesis}|\text{data})$."

# ╔═╡ d0c7b0da-8195-11eb-2451-7b38d10df088
md"### How do we work out the posterior?
If a Bayesian wants to make claims about hypotheses, not about how consistent data is with a hypothesis, then how do they do that?

Funnily enough, with Baye's Equation.

$P(\text{hypothesis} | \text{data}) \propto P(\text{data} | \text{hypothesis}) \cdot P(\text{hypothesis})$

where:
- ``P(\text{hypothesis} | \text{data})`` is the posterior 
- ``P(\text{data} | \text{hypothesis})`` is the likelihood
- ``P(\text{hypothesis})`` is the prior

Let's just recap, because we are getting into equations, but what we are doing is conceptually very simple...

Baye's equation simply says... to work out what we believe about a hypothesis (given some data), all we need to do is to mulitple the probability of seeing that data given the hypothesis is true, mulitplied by the probability that the hypothesis is true.
"

# ╔═╡ 48deda2c-819f-11eb-1fc5-c7f220cdc4db
md"### Baye's equation and the shark example
Let's have a quick look to see how Baye's equation can help us calculate the posterior, $P(\text{head bitten off by shark} | \text{died in last 2 years})$. We will do this using the prior and the likelihood.

The **likelihood** (which we can also call our data generating model) specifies $P(\text{died in last 2 years} | \text{head bitten off by shark}) = 1$. We already discussed how this is equal to 1, because it is certain that you will be dead within 2 years of having your head bitten off by a shark."

# ╔═╡ 3ef5c598-819f-11eb-3d85-b75a11a9fe39
likelihood = 1.0

# ╔═╡ 17694b8e-81a0-11eb-0764-03927070d389
md"The **prior** is something that we can change using this slider below, but it will be a number between 0 and 1, representing our prior belief that someone who died within 2 years had their head bitten off by a shark:
"

# ╔═╡ 998e5836-819e-11eb-30a3-1704d76ca122
@bind prior Slider(0.00 : 0.01 : 1.0)

# ╔═╡ f90deb1a-819d-11eb-1a88-abfa9692dc88
md"
**Prior:** ``P(\text{shark bit head off})`` = $prior

**Posterior:** ``P(\text{shark bit head off} | \text{died in last 2 years})`` = 1 ``\times`` $prior = $(likelihood * prior)

This is a simple example, but it shows how by using Baye's equation, we can multiply the likelihood by the prior to arrive at our posterior.
"

# ╔═╡ 09cb2994-81a2-11eb-3750-f5b6b92c9a7a
md"Now we will go forth and apply what we have learnt to our T-Test case study."

# ╔═╡ 63e00578-81a2-11eb-23af-09b36db5ab85
md"# Part II - Frequentist T-Test"

# ╔═╡ 73a70344-81a2-11eb-0983-0147ed43f12e


# ╔═╡ 738a864c-81a2-11eb-0352-37fa8997ecc5


# ╔═╡ 735d335e-81a2-11eb-2eaa-d9a8ce7e3a0d
md"# Part III - Bayesian T-Test"

# ╔═╡ 73436ee2-81a2-11eb-3f5c-49655225012d


# ╔═╡ d032686a-8195-11eb-30f4-358f07266931
md"# References
- Dienes, Z. (2008). Understanding Psychology as a Science: An Introduction to Scientific and Statistical Inference. Palgrave Macmillan.
"

# ╔═╡ 8cd18344-81a2-11eb-342b-112549bb58b1
md"Code blocks below are just setup stuff to make eveything work. I am hiding them away in order to focus on the concepts rather than mundane practical aspects of the code."

# ╔═╡ 82703e04-81a2-11eb-05e5-c168ca10f7c6
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));

# ╔═╡ a6bf5f2e-8198-11eb-2392-33dbf7ad80b2
hint(md"$P(\text{head bitten off by shark} | \text{dead within 2 years}) \sim 0$")

# ╔═╡ 30187ce6-819a-11eb-1678-dde16ff33b1a
correct(text) = Markdown.MD(Markdown.Admonition("correct", "Important point", [text]));

# ╔═╡ f4fc8d02-819c-11eb-2235-b5d793b04828
correct(md"This is pretty cool! We have broken free of the shakles of confinement of making claims about data. Now we can make claims about hypotheses! This is what we are very often interested in doing as scientists.")

# ╔═╡ Cell order:
# ╟─8b6ff28c-818a-11eb-2421-41fa4a9aeedd
# ╟─de82e978-818c-11eb-11bf-ffa1249a932a
# ╟─aa32c604-818f-11eb-0fac-c9794460f86e
# ╟─d15e3ade-8193-11eb-2035-4bbf81b664c1
# ╟─edc51308-8190-11eb-1045-11be03efce84
# ╟─a6bf5f2e-8198-11eb-2392-33dbf7ad80b2
# ╟─246aef2c-819b-11eb-2aa0-d7d5b1834e3c
# ╟─d0c7b0da-8195-11eb-2451-7b38d10df088
# ╟─48deda2c-819f-11eb-1fc5-c7f220cdc4db
# ╟─3ef5c598-819f-11eb-3d85-b75a11a9fe39
# ╟─17694b8e-81a0-11eb-0764-03927070d389
# ╟─998e5836-819e-11eb-30a3-1704d76ca122
# ╟─f90deb1a-819d-11eb-1a88-abfa9692dc88
# ╟─f4fc8d02-819c-11eb-2235-b5d793b04828
# ╟─09cb2994-81a2-11eb-3750-f5b6b92c9a7a
# ╠═63e00578-81a2-11eb-23af-09b36db5ab85
# ╠═73a70344-81a2-11eb-0983-0147ed43f12e
# ╠═738a864c-81a2-11eb-0352-37fa8997ecc5
# ╠═735d335e-81a2-11eb-2eaa-d9a8ce7e3a0d
# ╠═73436ee2-81a2-11eb-3f5c-49655225012d
# ╟─d032686a-8195-11eb-30f4-358f07266931
# ╟─8cd18344-81a2-11eb-342b-112549bb58b1
# ╠═01591408-819d-11eb-3f81-73b53fa7e515
# ╠═82703e04-81a2-11eb-05e5-c168ca10f7c6
# ╠═30187ce6-819a-11eb-1678-dde16ff33b1a
