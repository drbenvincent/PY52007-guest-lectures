import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np


def figure_data_parameter_space(x, y, true_m=None, true_c=None, m_prior=None, c_prior=None, posterior=None):
    """Create a multi-part figure of data space and parameter space"""
    
    fig, ax = plt.subplots(nrows=1, ncols=2, figsize=(12, 6))
    
    # PLOT DATA SPACE ===================================================
    
    # plot data
    ax[0].plot(x, y, 'ko')
    
    x_range = [np.min(x), np.max(x)]
    
    # plot true model
    if true_m is not None and true_c is not None:
        xi = np.linspace(x_range[0], x_range[1], 2)
        yi = true_m * xi + true_c
        ax[0].plot(xi, yi, 'r-', label="true")

    # plot samples from prior
    if posterior is None and m_prior is not None and c_prior is not None and true_m is not None and true_c is not None:
        for _ in range(50):
            xi = np.linspace(x_range[0], x_range[1], 2)
            yi = m_prior.rvs() * xi + c_prior.rvs()
            ax[0].plot(xi, yi, 'k', alpha=0.1)
                
    
            
    # PLOT PARAMETER SPACE ==============================================

    if posterior is not None:
        # POSTERIOR
        mi, ci, post = posterior
        img = plt.pcolormesh(mi, ci, post, cmap=cm.Blues_r)
        cbar = fig.colorbar(img, ax=ax[1])
        cbar.ax.set_ylabel("Probability")
        # calculate posterior mode (m,c)
        ind = np.unravel_index(np.argmax(post, axis=None), post.shape)
        m_best_guess, c_best_guess = mi[ind[1]], ci[ind[0]]
        # plot best guess
        ax[1].plot(m_best_guess, c_best_guess, 'bo', label='best guess')
        
        # plot best guess model line
        xi = np.linspace(x_range[0], x_range[1], 2)
        yi = m_best_guess * xi + c_best_guess
        ax[0].plot(xi, yi, 'b-', label="best guess")
                   
    elif m_prior is not None and c_prior is not None:
        # PRIOR
        mi = np.linspace(-3, 3, 100)
        ci = np.linspace(-3, 3, 100)
        mv, cv = np.meshgrid(mi, ci, sparse=False, indexing="xy")
        prior = m_prior.pdf(mv) * c_prior.pdf(cv)
        prior = prior/np.sum(prior)
        img = ax[1].pcolormesh(mv, cv, prior, cmap=cm.Blues_r)
        cbar = fig.colorbar(img, ax=ax[1])
        cbar.ax.set_ylabel("Probability")
        
    # plot true parameters as a point
    if true_m is not None and true_c is not None:
        ax[1].plot(true_m, true_c, 'ro', label="true")
        ax[1].set(xlabel="slope, $m$", ylabel="intercept, $c$")
    
    # formatting
    ax[0].set_title('Data space')
    ax[0].set(xlabel="independent variable, $x$", ylabel="dependent variable, $y$")
    ax[0].legend() 
    
    ax[1].set_title('Parameter space')
    ax[1].legend()
    
    # spacing between columns
    fig.subplots_adjust(wspace=0.3)
    

def plot_posterior_m(post, mi):
    fig, ax = plt.subplots(figsize=(12, 6))

    # plot posterior
    posterior_m = np.sum(post, axis=0)
    posterior_m /= np.sum(posterior_m)
    ax.plot(mi, posterior_m, label="posterior", lw=3)
    # shade the 95% region
    x = np.cumsum(posterior_m)
    y = mi
    m95 = np.interp([0.05 / 2, 1 - (0.05 / 2)], x, y)
    m95
    ax.fill_between(
        mi,
        0,
        posterior_m,
        where=np.logical_and(mi >= m95[0], mi <= m95[1]),
        alpha=0.3,
        label="95% credible region",
    )

    plt.axvline(x=0, c="k", ls="--")

    ax.set(xlabel="slope, $m$", ylabel="probability")
    ax.legend()
    
    
def plot_m_bayes_factor(mi, post, prior_dist):
    """
    prior_dist is a scipy distribution
    """
    fig, ax = plt.subplots(figsize=(12, 6))
    

    # plot posterior
    posterior_m = np.sum(post, axis=0)
    posterior_m /= np.sum(posterior_m)
    ax.plot(mi, posterior_m, label="posterior", lw=3)
    
    # plot prior
    prior = prior_dist.pdf(mi)
    prior /= sum(prior)
    ax.plot(mi, prior, label="prior", lw=3)
    
    # calculate Bayes Factor
    prior_prob = np.interp(0, mi, prior)
    post_prob = np.interp(0, mi, posterior_m)
    bf10 = post_prob/prior_prob

    plt.axvline(x=0, c="k", ls="--")

    ax.set(xlabel="slope, $m$", 
           ylabel="probability", 
           title=r"$BF_{10}=$" + f"{bf10}" + r", $BF_{01}=$" + f"{1/bf10}")
    ax.legend()