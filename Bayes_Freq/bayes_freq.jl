### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c0e909ea-81e5-11eb-228d-91f889aff616
using DataFrames

# ╔═╡ 01591408-819d-11eb-3f81-73b53fa7e515
using PlutoUI, CSV, Statistics, Distributions, StatsPlots

# ╔═╡ 8b6ff28c-818a-11eb-2421-41fa4a9aeedd
md"# Frequentist vs Bayesian inference
Dr Benjamin T. Vincent

NOTE: This session is an amalgamation of 2 previous lectures that have looked at [Hypothesis Testing](https://github.com/drbenvincent/PY52007-guest-lectures/blob/2021/Hypothesis%20testing/Hypothesis%20Testing.ipynb) in detail, and [Bayesian inference](https://github.com/drbenvincent/PY52007-guest-lectures/blob/2021/Bayesian%20inference/Bayesian_Inference_Part1.ipynb) in detail. This session is an attempt to combine these topics. So this session is not simply a combination of those previous sessions, we cover different examples and have different emphases. So it may be that in working through this material in your own time, going back to refer to these other sessions could be very useful as they go into more depth in certain places.
"

# ╔═╡ 2d66437e-8259-11eb-3e55-3d02b484250b
md"## 🚨List of TODO's for Ben to further improve this notebook 🚨
- Plot density in Bayes Factor plot properly, rather than normalised probability density.
- Figure out how JASP deals with $\sigma$ to more closely replicate their result.
- Add animated graphic where you can chance the Cauchy prior (mean and variance) to see the effect on the posterior.
- Firm up my wording on the interpretation of Bayes Factors - evidence for $H_0$ and $H_1$ vs evidence of $H_0$ under prior and posterior.
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
This figure below shows the kind of output you get from a Bayesian version of the same statistical test in JASP. The key result here is what is known as a Bayes Factor, $BF_{10}=2.217$. But we also get a nice graphical output. At the moment this might look all very mysterious, but by the end of this session you should understand it 🙂.

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
@bind shark_prior Slider(0.00 : 0.01 : 1.0)

# ╔═╡ f90deb1a-819d-11eb-1a88-abfa9692dc88
md"
**Prior:** ``P(\text{shark bit head off})`` = $shark_prior

**Posterior:** ``P(\text{shark bit head off} | \text{died in last 2 years})`` = 1 ``\times`` $shark_prior = $(likelihood * shark_prior)

This is a simple example, but it shows how by using Baye's equation, we can multiply the likelihood by the prior to arrive at our posterior.
"

# ╔═╡ 09cb2994-81a2-11eb-3750-f5b6b92c9a7a
md"Now we will go forth and apply what we have learnt to our T-Test case study."

# ╔═╡ 63e00578-81a2-11eb-23af-09b36db5ab85
md"# Part II - Frequentist T-Test
So far we have introduced our motivating example of an independent samples T-Test. We saw that the output you get in JASP or Frequentist and Bayesian version of the test are rather different. We then started on our journey of understanding the differences between the approaches on a conceptual level. Of particular relevance for the Frequentist approach was the likelihood term, which can be desribed as the data generating process.

Here we return to our T-Test example and show, through simulation approaches, exactly what the Frequentist approach does. As I mentioned in the beginning, I have a existing material on [Hypothesis testing](https://github.com/drbenvincent/PY52007-guest-lectures/blob/2021/Hypothesis%20testing/Hypothesis%20Testing.ipynb), there will be some overlap, but you may wish to refer to that for more detail, and a different example.

## The 'logic' of frequentist hypothesis testing
There are many different statistical tests. It can be confusing which one you should use and why. What are all the different statistics and where do they come from? We can think about this in a simpler way:

By thinking about simulating experiments (rather than doing maths), we can see that there is only one core procedure used in the hypothesis testing approach.
![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/f83a2a113af0f1258753e449a3e47276e4f8759c/Hypothesis%20testing/figs/flow.png)
_Figure by Allen Downney from this blog post [http://allendowney.blogspot.com/2016/06/there-is-still-only-one-test.html](http://allendowney.blogspot.com/2016/06/there-is-still-only-one-test.html)_

The data is relatively straightforward. It is just a table of data that you have collected. You might have columns for different measures and rows for each observation.

In order to test your hypothesis, you construct a test statistic. This takes your data and reduces it to a single number which captures the size of the effect that you are interested in. Example hypotheses could be:

- The mean of group A is different than group B.
- The median of group A is different than group B. (Might be more robust to outliers).
- The mean of group A is higher than group B. (A directional hypothesis).
- Each individual increased their score from condition A to condition B. (As in a repeated measures context).
- Etc.

We could come up with a whole range of statistics (ways of converting a dataset into an effect size) which test different hypotheses. We will look at an example below.

Then the heart of the hypothesis testing approach comes in... You need to work out what are the chances of seeing an effect (a test statistic), for your particular dataset, as big as this by chance. If your effect size is low, then it is more consistent with chance as compared to if your effect size is large.

So how do we do this, specifically? We define a null hypothesis, $H_0$, which states what we would expect to see if there is no effect. This is the 'top down' or deductive approach, where we say, _assuming the null and a certain experiment structure and a certain sample size, then I expect to see this._

This allows you to work out the consistency (also known as the likelihood) of the data given the null hypothesis, which we could call $P(data|H_0)$.
"

# ╔═╡ ff3fbaf2-81a4-11eb-3794-5901c9c2e11e
md"### Frequentist independent T-Test by hand
So we are going to follow this approach and simulate what we would expect to see, assuming $H_0$. Before doing that, we need to understand a bit about our dataset.
"

# ╔═╡ 738a864c-81a2-11eb-0352-37fa8997ecc5
data = CSV.read("Directed_Reading_Activities.csv", DataFrame)

# ╔═╡ 949dfcd8-81bd-11eb-051a-f9143fc71478
begin
	plot(size=(650, 200))
	histogram!(data.drp[data.group .== "Treat"], 
		bins=10, label="Treat", alpha=0.5)
	histogram!(data.drp[data.group .== "Control"], 
		bins=15, label="Control", alpha=0.5)
end

# ╔═╡ 9e837d6c-81a5-11eb-1df2-4fd2c7a36f72
md"Let's see how many participants we have in the control and treatment groups"

# ╔═╡ 2c02ec26-81a5-11eb-1b3a-236ef387e110
N_treat = sum(data.group .== "Treat")

# ╔═╡ 565f84d4-81a5-11eb-2d75-45d0b0c999e1
N_control = sum(data.group .== "Control")

# ╔═╡ beacd850-81a7-11eb-11c8-c3733fcdc1ea
md"Now let's calculate the t-statistic (equal variances assumed) for our data. As I mentioned, you could do this with a much simpler statistic (e.g. difference in means), but the t-statistic has some more desirable properties in how it is affected by group variance etc, so we will look up the t-statistic equation and use that.

$t = \frac{\bar{x}_1 - \bar{x}_2}{s_p \sqrt{ 1/n_1 + 1/n_2 }}$

where

$s_p = \sqrt{ \frac{(n_1-1)s_1^2 + (n_2-1)s_2^2}{n_1 +n_2 -2} }$
"

# ╔═╡ b8124ffc-81b3-11eb-2c19-ad5d4e868ff6
function pooled_std(x, y)
	numerator = (length(x) - 1) * var(x) + (length(y) - 1) * var(y)
	denom = (length(x) + length(y)-2)
	return √(numerator / denom)
end;

# ╔═╡ 70ed51a6-81b3-11eb-2cc8-b59172453297
function t_statistic(x, y)
	return (mean(x) - mean(y)) / 
	(pooled_std(x, y) * sqrt(1/length(x) + 1/length(y)))
end;

# ╔═╡ 79eb800c-8244-11eb-22ba-09fa882a3ee7
md"So let's use that to calculate the t-statistic for our data."

# ╔═╡ db3df5a6-81a4-11eb-3259-6513e68aaa26
t_observed = t_statistic(data.drp[data.group .== "Treat"], 
	                     data.drp[data.group .== "Control"])

# ╔═╡ eb38dd72-81a7-11eb-13a5-fb33865c1989
md"So the t-statistic for our dataset is $t_observed. Nice. But what does this mean? Is it a small number or a large number? How does it compare to what we'd expect to see under the null hypothesis?

In order to work that out, we will follow the simulation approach in the flow diagram above."

# ╔═╡ db7efdc6-81a4-11eb-0e48-cf004c81f59a
md"Define the generative model

$\alpha = \delta \cdot \sigma$ 

$x_i \sim \text{Normal} \Big( \mu - \frac{\alpha}{2}, \sigma \Big), i = 1, \ldots, N_{\text{treat}}$

$y_i \sim \text{Normal} \Big( \mu + \frac{\alpha}{2}, \sigma \Big), i = 1, \ldots, N_{\text{control}}$

Note that the effect size $\delta = \alpha / \sigma$
"

# ╔═╡ 122df8d8-81a8-11eb-0540-699877337ac9
function generative_process(α, N_treat, N_control)
	μ, σ = 0, 1
	x = rand(Normal(μ + α/2, σ), N_treat)
	y = rand(Normal(μ - α/2, σ), N_control)
	return x, y
end;

# ╔═╡ 050d79b6-81ae-11eb-280d-c5223c23055a
md"Choose a value for $\alpha$. Note that $H_0$ is that there is no difference between the group, and when $H_0$ is true, $\alpha=0$."

# ╔═╡ 24e29984-81ad-11eb-1cc6-ffebec8641ff
@bind α Slider(0.00 : 0.01 : 5.0)

# ╔═╡ 11f76372-81a8-11eb-2ab2-3d2b6de88c5a
begin
	x, y = generative_process(α, N_treat, N_control);
	density(x, label="control", lw=3)
	density!(y, label="treatment", lw=3)
	t_value = t_statistic(x, y)
	plot!(xlabel="observed value", 
		  title="α = $α; t = $t_value\nN_treat = $N_treat, N_control=$N_control",
		  xlim=[-5, 5])
	vline!([+α/2], color=:black, label="alpha/2")
	vline!([-α/2], color=:black, linestyle=:dash, label="-alpha/2")
end

# ╔═╡ 43ad5d44-81ae-11eb-0b30-451a156bcbcc
md"Now what we want to do is to repeat this simulation many times to calculate a distribution of what t-statistic values we would expect to see under $H_0$. The steps are:
1. Set $\alpha=0$ to correspond to $H_0$
2. Use the generative process to simulate data we'd expect to see.
3. Calculate the t-statistic for that simulated dataset.
4. Repeat steps 2-3 many times, building up a list of t-statistic values.
5. Work out the proportion of the time the observed t-statistic is greater than what we'd expect under $H_0$.
" 

# ╔═╡ d8981e76-8244-11eb-2c8b-f55cb91169ea
function many_simulations(n_simulations, N_treat, N_control)
	t_vec = []
	for n = 1 : n_simulations
		# Note: we assume alpha = 0
		x, y = generative_process(0, N_treat, N_control)
		append!(t_vec, t_statistic(x, y))
	end
	return t_vec
end;

# ╔═╡ cfa47eec-81e3-11eb-1658-5b4a58fe9bfd
md"Note that we are using a 2-tailed test in that we are not making a directional hypothesis. Therefore we need compare the distribution of t-statistics to the _absolute value_ of the observed t-statistic."

# ╔═╡ 437a9eea-81ae-11eb-0d6f-ef8073af86d9
function p_two_tailed(observed, distribution)
	sum(abs.(distribution) .> observed) / length(distribution)
end;

# ╔═╡ 140ee084-8245-11eb-0d3b-3929a2b48b52
md"Choose the number of simulations with the slider:"

# ╔═╡ 17a5965c-81af-11eb-3a52-b3627fc436b8
@bind n_simulations Slider(100 : 100 : 500_000)

# ╔═╡ 43932faa-81ae-11eb-06a5-29bda5d2ce54
begin
	t_vec = many_simulations(n_simulations, N_treat, N_control)
	
	p = p_two_tailed(t_observed, t_vec)
	
	density(t_vec, title="t-statistic under H0\n p=$p\n $n_simulations simulations", 
			label="", lw=3)
	plot!(xlabel="t-statistic value", xlim=[-4, 4])
	vline!([t_observed], label="observed t-statistic")
end

# ╔═╡ e2e518d8-81b9-11eb-2c55-1bdd73057d60
md"## Recap

Let's circle back to the output we got from the Frequentist independent samples T-Test:
![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/2021/Bayes_Freq/img/results_freq.png)

We were able to replicate the t-statistic value _and_ the p-value using our simulation based approach. Hopefully this all clarifies how Frequentist hypothesis testing works. The most important points are:
- The Frequentist approach uses a data generating process. We assume $H_0$ is true and then simulate data consistent with this hypothesis.
- By repeatedly simulating possible datasets under $H_0$, then we can calculate a distribution of t-statistics we would expect to see.
- We can then compare that to the t-statistic value for the actual data that we observed. This allows us to see how likely or unlikely the observed t-statistic value is 
- We can then make claims about the plausibility of the data under the null hypothesis, $P(\text{data}|H_0)$, which we know as the likelihood.
- But we must be aware that this does _not_ allow us to make any claims about how likely the null hypothesis is to be true or false. 

What you _cannot_ say:
- I have falsified the null hypothesis.
- There is a 95% chance of the null hypothesis being false

What you _can_ say:
- If I theoretically repeated the same experiment a very large number of times, then I would expect to get a statistic value this extreme or more p=$p of the time.
- If I conclude that $H_0$ is false, I would be wrong $(p*100)% of the time.

I highly recommend checking out my other [Hypothesis Testing notebook]([Hypothesis testing](https://github.com/drbenvincent/PY52007-guest-lectures/blob/2021/Hypothesis%20testing/Hypothesis%20Testing.ipynb)) which goes into this in more depth.
"

# ╔═╡ 735d335e-81a2-11eb-2eaa-d9a8ce7e3a0d
md"# Part III - Bayesian T-Test

It's been a while, so let's recap the kind of output that we get from the Bayesian version of the independent samples T-Test.

![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/2021/Bayes_Freq/img/results_bayesian.png)

The most important points we will cover are:
- How to understand the main result, the Bayes Factor, $BF_{01}=0.451$
- How to understand the prior and posterior over effect sizes, $\delta$.

To pre-empt our full understanding:
1. The prior curve represents the relative plausibility/credibility in different effect sizes prior to having seen the data. This prior knowledge could be based upon our knowledge of the effect sizes that we observe in psychological experiments.
2. The posterior curve represents the credibility of effect sizes after having observed the data. This is arrived at using Baye's equation.
3. The Bayes Factor describes whether the credibility of $H_0$ (effect size is zero) has gone up or down, and by how much, after having seen the data relative to our prior beliefs.

One of the major conceptual leaps here is that we no longer just consider one hypothesis, such as $H_0$ which states that group differences are zero. We saw in the generative model, this was done by setting $\alpha=0$. 

In the Bayesian approach we actually consider a whole span of hypotheses and consider the credibility for a range of effect sizes consistent with our prior beliefs or our posterior beliefs after having seen the data. 
"

# ╔═╡ 73436ee2-81a2-11eb-3f5c-49655225012d
md"## Define the generative model

This is basically the same generative model as before. The only real difference is that we can define our prior beliefs about the effect size, $\delta$.

$\delta \sim \mathrm{Cauchy}(0, 0.707)$

$\sigma = ???????$

$\alpha = \delta \cdot \sigma$ 

$x_i \sim \text{Normal} \Big( \mu - \frac{\alpha}{2}, \sigma \Big), i = 1, \ldots, N_{\text{treat}}$

$y_i \sim \text{Normal} \Big( \mu + \frac{\alpha}{2}, \sigma \Big), i = 1, \ldots, N_{\text{control}}$

Let's look at these components:
- ``\delta`` is the effect size and is defined as ``\delta = \alpha \cdot \sigma``.
- ``\alpha`` is the distance between the group means.
- ``\sigma`` is the standard deviation of the data.
- ``x_i`` defines the likelihood of the data from the treatment group.
- ``y_i`` defines the likelihood of the data from the control group.

Note that the effect size $\delta = \alpha / \sigma$
"

# ╔═╡ 97347b74-81d0-11eb-009b-33178b6218c3
effect_sizes = LinRange(-10, 10, 1000);

# ╔═╡ 18aa5896-81d3-11eb-213b-7d8b0bfd743b
md"Calculate the posterior probability for a given effect size $\delta$."

# ╔═╡ 44381090-81ce-11eb-2a9f-65aee384155d
function calc_posterior(δ, σ, treat, control)
	lp = 0.0  # Note we sum log posteriors
	α = δ * σ
	# prior
	lp += logpdf(Cauchy(0, 0.707), δ)
	# likelihood
	lp += sum(logpdf(Normal(-α/2, σ), treat))
	lp += sum(logpdf(Normal(α/2, σ), control))
	return exp(lp)  # return posterior, not the log posterior
end;

# ╔═╡ 980d5fea-81c9-11eb-2f50-cbbe3d40e5e8
function calc_posterior_for_many_effect_sizes(treat, control)
	σ = pooled_std(treat, control)  # SORT THIS OUT !!!!!!!!!!!!!!!!!
	post = [calc_posterior(δ, σ, treat, control) for δ in effect_sizes]
	return  post ./ sum(post)  # normalise
end;

# ╔═╡ 97f92084-81c9-11eb-35e0-dfef6a781db9
posterior_prob = calc_posterior_for_many_effect_sizes(
	data.drp[data.group .== "Treat"],
	data.drp[data.group .== "Control"]);

# ╔═╡ 3d865c1c-81e6-11eb-2096-0f7ab41c44c5
md"Let's look at the results. We know they only approximate the results that JASP gives.

Here we can see the the credibility that the effect size equals zero ($\delta=0$) has now gone up slightly after having observed the data. This constrasts to the result given by JASP.

The discrepancy is simply because I have not yet fully understood how they deal with the $\sigma$ parameter."

# ╔═╡ b36d2060-81cc-11eb-3633-b17313552c9f
begin
	# plot prior
	prior = pdf(Cauchy(0, 0.707), effect_sizes)
	prior_n = prior ./ sum(prior)  # Normalise
	plot(effect_sizes, prior_n, lw=3, 
		linestyle=:dash, color=:black, xlim=[-2, 2], label="Prior")
	plot!(xlabel="Effect size δ")
	
	# plot posterior
	plot!(effect_sizes, posterior_prob, 
		xlim=[-2, 2], lw=3, color=:black, label="posterior")
end

# ╔═╡ c9b579f2-81e6-11eb-2b6e-772227a6aff3
md"![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/2021/Bayes_Freq/img/results_bayesian.png)

But let's interpret the JASP result:
![](https://raw.githubusercontent.com/drbenvincent/PY52007-guest-lectures/f83a2a113af0f1258753e449a3e47276e4f8759c/Bayesian%20inference/img/bftable.png)

So for the JASP result, you could say:
- The most likely effect size is $\delta=-0.568$, and the 95% Bayesian credible intervals do not overlap with zero (just).
- Relative to my prior beliefs, the credibility in the null hypothesis ($\delta=0$) has gone _down_ by 2.2 times after having observed the data.
- By convention, a Bayes Factor of 2.2 is classed as _anecdotal evidence_ and so I will not seek to draw strong research conclusions either way.
- The 'dart board' part of the plot gives an indication of how surprised you should be if you throw a dart and it hits $H_0$ or $H_1$.

Note: there are different schools of thought about the relative importance of Bayes Factors vs Bayesian credible intervals. But the tide seems to be in favour of Bayes Factors when it comes to hypothesis testing.
"

# ╔═╡ f2dcfd90-81e2-11eb-2e7f-57e0c331045e
md"If you are interested in this particular way of explaining the Bayesian approach, then I would recommend a previous [Bayesian inference notebook](https://github.com/drbenvincent/PY52007-guest-lectures/blob/2021/Bayesian%20inference/Bayesian_Inference_Part1.ipynb) which focusses on a linear regression example. There is also an accompanying [YouTube video](https://www.youtube.com/watch?v=OwQnUr6rLHA)." 

# ╔═╡ 4dafaa9e-81e1-11eb-1087-1130c9854643
md"# Summary

We can do hypothesis testing in the Frequentist and Bayesian approaches. There are similarities and differences.
- Similar in having a level of evidence which is compared to a threshold (or thresholds) which is decided by convention.
- But the Frequentist approach only allows you to make claims about data.
- Very often, as scientists, we are interested in making claims about hypotheses.
- The Bayesian approach allows you to do this.
- It is conceptually simple, in terms of incorporating your prior beliefs and information from the data (via the likelihood) to arrive at your final belieds (the posterior.

There are many other aspects of Frequentism vs Bayesianism which I've not touched upon here, but hopefully this has served as a good foundation to build upon.

Any questions for me?"

# ╔═╡ d032686a-8195-11eb-30f4-358f07266931
md"# References
- Dienes, Z. (2008). Understanding Psychology as a Science: An Introduction to Scientific and Statistical Inference. Palgrave Macmillan.
- Rouder, J. N., Speckman, P. L., Sun, D., Morey, R. D., & Iverson, G. (2009). Bayesian t tests for accepting and rejecting the null hypothesis. Psychonomic Bulletin & Review, 16(2), 225–237. http://doi.org/10.3758/PBR.16.2.225
"

# ╔═╡ 8cd18344-81a2-11eb-342b-112549bb58b1
md"Code blocks below are just setup stuff to make eveything work. I am hiding them away in order to focus on the concepts rather than mundane practical aspects of the code."

# ╔═╡ 82703e04-81a2-11eb-05e5-c168ca10f7c6
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));

# ╔═╡ 6473816a-81e1-11eb-33f0-9166ad7490c4
hint(md"Some thoughts:
- We often want to make claims about the credibility of hypotheses. We cannot do this under the Frequentist approach
- Rejecting $H_0$ is not a very strong statement, rather than rejecting what is not the case, maybe it would be better if we could make statements about what _is_ the case.
")

# ╔═╡ a6bf5f2e-8198-11eb-2392-33dbf7ad80b2
hint(md"$P(\text{head bitten off by shark} | \text{dead within 2 years}) \sim 0$")

# ╔═╡ 30187ce6-819a-11eb-1678-dde16ff33b1a
correct(text) = Markdown.MD(Markdown.Admonition("correct", "Important point", [text]));

# ╔═╡ f4fc8d02-819c-11eb-2235-b5d793b04828
correct(md"This is pretty cool! We have broken free of the shakles of confinement of making claims about data. Now we can make claims about hypotheses! This is what we are very often interested in doing as scientists.")

# ╔═╡ 9d58e5cc-81b6-11eb-3433-bd02e2354dc6
correct(md"Our t-statistic for our dataset is $t_observed. Compare that to the t-statistic calculated through JASP, up at the top of this notebook. It's the same!")

# ╔═╡ db2435da-81a4-11eb-1af0-3d4c18386433
correct(md"The two-tailed p-value using our simulation approach is $p. We got a ``p=0.029`` from JASP, so that is a match when our estimates are based on a large number of simulated datasets.")

# ╔═╡ 56ce5f38-81d4-11eb-227d-43aa021ab15e
danger(text) = Markdown.MD(Markdown.Admonition("danger", "Warning!", [text]));

# ╔═╡ 67938cda-81d4-11eb-2f44-1902dbe7586d
danger(md"The results I present here are not exactly the same as in JASP. This is because I am not yet 100% sure how they deal with the $\sigma$ variable. But it is close enough to get the idea! I will continue on this front and update the notebook when I figure it out.")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
CSV = "~0.9.11"
DataFrames = "~1.3.0"
Distributions = "~0.25.34"
PlutoUI = "~0.7.21"
StatsPlots = "~0.14.29"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "abb72771fd8895a7ebd83d5632dc4b989b022b5b"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.2"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[deps.Arpack_jll]]
deps = ["Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "e214a9b9bd1b4e1b4f15b22c0994862b66af7ff7"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.0+3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "49f14b6c56a2da47608fe30aed711b5882264d7a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.11"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[deps.ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "2e993336a3f68216be91eb8ee4625ebbaba19147"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "7f3bec11f4bcd01bc1f507ebce5eadf1b0a78f47"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.34"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fd75fa3a2080109a2c0ec9864a6e14c60cca3866"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.62.0+0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "74ef6288d071f58033d54fd6708d4bc23a8b8972"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "ca99cac337f8e0561c6a6edeeae5bf6966a78d21"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "8d958ff1854b166003238fe191ec34b9d592860a"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.8.0"

[[deps.NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun"]
git-tree-sha1 = "3e7e9415f917db410dcc0a6b2b55711df434522c"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "b68904528fd538f1cb6a3fbc44d2abdc498f9e8e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.21"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "f45b34656397a1f6e729901dc9ef679610bd12b5"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.8"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
git-tree-sha1 = "0f2aa8e32d511f758a2ce49208181f7733a0936a"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.1.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "bedb3e17cc1d94ce0e6e66d3afa47157978ba404"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.14"

[[deps.StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "d6956cefe3766a8eb5caae9226118bb0ac61c8ac"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.29"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "80661f59d28714632132c73779f8becc19a113f2"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.4"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─8b6ff28c-818a-11eb-2421-41fa4a9aeedd
# ╟─2d66437e-8259-11eb-3e55-3d02b484250b
# ╟─de82e978-818c-11eb-11bf-ffa1249a932a
# ╟─aa32c604-818f-11eb-0fac-c9794460f86e
# ╟─d15e3ade-8193-11eb-2035-4bbf81b664c1
# ╟─6473816a-81e1-11eb-33f0-9166ad7490c4
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
# ╟─63e00578-81a2-11eb-23af-09b36db5ab85
# ╟─ff3fbaf2-81a4-11eb-3794-5901c9c2e11e
# ╠═c0e909ea-81e5-11eb-228d-91f889aff616
# ╠═738a864c-81a2-11eb-0352-37fa8997ecc5
# ╟─949dfcd8-81bd-11eb-051a-f9143fc71478
# ╟─9e837d6c-81a5-11eb-1df2-4fd2c7a36f72
# ╟─2c02ec26-81a5-11eb-1b3a-236ef387e110
# ╟─565f84d4-81a5-11eb-2d75-45d0b0c999e1
# ╟─beacd850-81a7-11eb-11c8-c3733fcdc1ea
# ╠═70ed51a6-81b3-11eb-2cc8-b59172453297
# ╠═b8124ffc-81b3-11eb-2c19-ad5d4e868ff6
# ╟─79eb800c-8244-11eb-22ba-09fa882a3ee7
# ╠═db3df5a6-81a4-11eb-3259-6513e68aaa26
# ╟─9d58e5cc-81b6-11eb-3433-bd02e2354dc6
# ╟─eb38dd72-81a7-11eb-13a5-fb33865c1989
# ╟─db7efdc6-81a4-11eb-0e48-cf004c81f59a
# ╠═122df8d8-81a8-11eb-0540-699877337ac9
# ╟─050d79b6-81ae-11eb-280d-c5223c23055a
# ╟─24e29984-81ad-11eb-1cc6-ffebec8641ff
# ╟─11f76372-81a8-11eb-2ab2-3d2b6de88c5a
# ╟─43ad5d44-81ae-11eb-0b30-451a156bcbcc
# ╠═d8981e76-8244-11eb-2c8b-f55cb91169ea
# ╟─cfa47eec-81e3-11eb-1658-5b4a58fe9bfd
# ╠═437a9eea-81ae-11eb-0d6f-ef8073af86d9
# ╟─140ee084-8245-11eb-0d3b-3929a2b48b52
# ╟─17a5965c-81af-11eb-3a52-b3627fc436b8
# ╟─43932faa-81ae-11eb-06a5-29bda5d2ce54
# ╟─db2435da-81a4-11eb-1af0-3d4c18386433
# ╟─e2e518d8-81b9-11eb-2c55-1bdd73057d60
# ╟─735d335e-81a2-11eb-2eaa-d9a8ce7e3a0d
# ╟─67938cda-81d4-11eb-2f44-1902dbe7586d
# ╟─73436ee2-81a2-11eb-3f5c-49655225012d
# ╠═97347b74-81d0-11eb-009b-33178b6218c3
# ╟─18aa5896-81d3-11eb-213b-7d8b0bfd743b
# ╠═44381090-81ce-11eb-2a9f-65aee384155d
# ╠═980d5fea-81c9-11eb-2f50-cbbe3d40e5e8
# ╠═97f92084-81c9-11eb-35e0-dfef6a781db9
# ╟─3d865c1c-81e6-11eb-2096-0f7ab41c44c5
# ╟─b36d2060-81cc-11eb-3633-b17313552c9f
# ╟─c9b579f2-81e6-11eb-2b6e-772227a6aff3
# ╟─f2dcfd90-81e2-11eb-2e7f-57e0c331045e
# ╟─4dafaa9e-81e1-11eb-1087-1130c9854643
# ╟─d032686a-8195-11eb-30f4-358f07266931
# ╟─8cd18344-81a2-11eb-342b-112549bb58b1
# ╠═01591408-819d-11eb-3f81-73b53fa7e515
# ╠═82703e04-81a2-11eb-05e5-c168ca10f7c6
# ╠═30187ce6-819a-11eb-1678-dde16ff33b1a
# ╠═56ce5f38-81d4-11eb-227d-43aa021ab15e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
