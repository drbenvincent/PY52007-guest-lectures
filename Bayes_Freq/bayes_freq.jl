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

# ╔═╡ c0e909ea-81e5-11eb-228d-91f889aff616
using DataFrames

# ╔═╡ 01591408-819d-11eb-3f81-73b53fa7e515
using PlutoUI, CSV, Statistics, Distributions, StatsPlots

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
md"So let's use that to calculat the t-statistic for our data."

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

# ╔═╡ Cell order:
# ╟─8b6ff28c-818a-11eb-2421-41fa4a9aeedd
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
