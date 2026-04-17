# Oncology Clinical Trial Referral Network

A simulated oncology clinical trial referral network from a major
research hospital. For the purpose of identifying collaboration networks
between oncologists, this dataset only includes referrals of patients
who were enrolled in more than one clinical trial. This includes 389
patients enrolled in 288 clinical trials.

## Usage

``` r
oncology_network
```

## Format

A `igraph` object (e.g. representing the oncology clinical trial
referral network. The structure includes:

- nodes:

  Oncologists or clinical trials (depending on network structure).

- edges:

  Referral links between nodes, based on shared patient enrollment
  across trials.

## Source

Simulated data based on oncology clinical trial enrollment patterns.

## Details

Clinical trials are categorized by intervention type, including targeted
therapies (prefixed with `"T:"`) and immunotherapies (prefixed with
`"I:"`). There are 16 distinct intervention types (nodes) and 470
patient referrals (edges) in the network.
