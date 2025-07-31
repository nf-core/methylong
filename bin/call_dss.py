#! /usr/bin/env python3
"""
this script is a modified version of dma module of NanoMethPhase written by Vahid Akbari, two minor changes:
    1. remove header in input files
    2. accept bedmethyl files
    3. remove "columns" arguments
    4. update default of DSS arguments
"""

import os
import glob
import gzip
import bz2
import argparse
import subprocess
from collections import defaultdict
import time


def openfile(file):
    '''
    Opens a file
    '''
    if file.endswith('.gz'):
        opened_file = gzip.open(file,'rt')
    elif file.endswith('bz') or file.endswith('bz2'):
        opened_file = bz2.open(file,'rt')
    else:
        opened_file = open(file,'r',encoding='utf-8')
    return opened_file


def main_dma(args):
    """
    This is the DMA module which does differential methylation analysis
    using DSS R package to find differentially methylated regions.
    """
    t_start = time.time()

    cases = []
    if args.case:
        case_items = args.case.split()
        for item in case_items:
            item = os.path.abspath(item)
            if os.path.isdir(item):
                for (dirpath, _, filenames) in os.walk(item):
                    for filename in filenames:
                        cases.append(os.path.join(dirpath, filename))
            elif os.path.isfile(item):
                cases.append(item)
            else:
                raise ValueError(f"Case item {item} does not exist!")
    else:
        raise ValueError("Case files or directories must be provided!")
    
    controls = []
    if args.control:
        control_items = args.control.split()
        for item in control_items:
            item = os.path.abspath(item)
            if os.path.isdir(item):
                for (dirpath, _, filenames) in os.walk(item):
                    for filename in filenames:
                        controls.append(os.path.join(dirpath, filename))
            elif os.path.isfile(item):
                controls.append(item)
            else:
                raise ValueError(f"Control item {item} does not exist!")
    else:
        raise ValueError("Control files or directories must be provided!")

    out_dir = os.path.abspath(args.out_dir)
    out_prefix = out_dir + '/' + (args.out_prefix)
    Rscript = args.Rscript  # os.path.abspath(args.Rscript)
    script = os.path.abspath(args.script_file)
    dis_merge = args.dis_merge
    minlen = args.minlen
    minCG = args.minCG
    smoothing_span = args.smoothing_span
    smoothing_flag = args.smoothing_flag.upper()
    equal_disp = args.equal_disp.upper()
    pval_cutoff = args.pval_cutoff
    delta_cutoff = args.delta_cutoff
    pct_sig = args.pct_sig

    # check if outputs exist
    check_outs = [x for x in glob.glob("{}*DM*.txt".format(out_prefix))]
    if check_outs and not args.overwrite:
        raise FileExistsError("The selected output files {} already "
                                "exist. Select --overwrite option if you "
                                "want to overwrite them or use a different "
                                "prefix".format(check_outs))

    subprocess.call(
        "{} {} {} {} {} {} {} {} {} {} {} {} {} {}".format(Rscript,
                                                           script,
                                                           ",".join(cases),
                                                           ",".join(controls),
                                                           out_prefix,
                                                           dis_merge,
                                                           minlen,
                                                           minCG,
                                                           smoothing_span,
                                                           smoothing_flag,
                                                           pval_cutoff,
                                                           delta_cutoff,
                                                           pct_sig,
                                                           equal_disp),
        shell=True)
    t_end1 = time.time()
    print("===DSS call DMR costs {:.1f} seconds".format(t_end1 - t_start))


def main():
    parser = argparse.ArgumentParser()
    dma_input = parser.add_argument_group("required arguments")
    dma_input.add_argument("--case", "-ca",
                           action="store",
                           type=str,
                           required=True,
                           help=("The path to the tab delimited input "
                                 "methylation frequency or ready input case "
                                 "file(s). If multiple files, files must be "
                                 "in the same directory and give the path to the directory."))
    dma_input.add_argument("--control", "-co",
                           action="store",
                           type=str,
                           required=True,
                           help=("The path to the tab delimited input "
                                 "methylation frequency or ready input "
                                 "control file(s). If multiple files, files must be "
                                 "in the same directory and give the path to the directory."))
    dma_input.add_argument("--out_dir", "-o",
                           action="store",
                           type=str,
                           required=True,
                           help="The path to the output directory")
    dma_input.add_argument("--out_prefix", "-op",
                           action="store",
                           type=str,
                           required=True,
                           help="The prefix for the output files")
    
    dma_opt = parser.add_argument_group("optional arguments")
    dma_opt.add_argument("--Rscript", "-rs",
                         action="store",
                         type=str,
                         required=False,
                         default="Rscript",
                         help="The path to a particular instance of "
                              "Rscript to use")
    dma_opt.add_argument("--script_file", "-sf",
                         action="store",
                         type=str,
                         required=False,
                         default=os.path.join(os.path.dirname(
                             os.path.realpath(__file__)
                         ),
                             "DSS_DMA.R"),
                         help="The path to the DSS_DMA.R script file")
    dma_opt.add_argument("--dis_merge", "-dm",
                         action="store",
                         type=int,
                         default=50,
                         required=False,
                         help=("When two DMRs are very close to each other "
                               "and the distance (in bps) is less than "
                               "this number, they will be merged into one. "
                               "Default is 50 bps."))
    dma_opt.add_argument("--minlen", "-ml",
                         action="store",
                         type=int,
                         default=50,
                         required=False,
                         help=("Minimum length (in basepairs) required for "
                               "DMR. Default is 100 bps."))
    dma_opt.add_argument("--minCG", "-mcg",
                         action="store",
                         type=int,
                         default=3,
                         required=False,
                         help=("Minimum number of CpG sites required for "
                               "DMR. Default is 3."))
    dma_opt.add_argument("--smoothing_span", "-sms",
                         action="store",
                         type=int,
                         default=500,
                         required=False,
                         help=("The size of smoothing window, in "
                               "basepairs. Default is 500."))
    dma_opt.add_argument("--smoothing_flag", "-smf",
                         action="store",
                         type=str,
                         default="TRUE",
                         required=False,
                         help=("TRUE/FALSE. A flag to indicate whether to , "
                               "appyly smoothing. Default is FALSE. We "
                               "recommend to use smoothing=TRUE for "
                               "whole-genome BS-seq data, and "
                               "smoothing=FALSE for sparser data such "
                               "like from RRBS or hydroxymethylation "
                               "data (TAB-seq). If there is not biological "
                               "replicate, smoothing=TRUE is required. "
                               "Default is TRUE"))
    dma_opt.add_argument("--equal_disp", "-ed",
                         action="store",
                         type=str,
                         default="TRUE",
                         required=False,
                         help=("TRUE/FALSE. When there is no biological "
                               "replicate in one or both treatment groups, "
                               "users can either (1) specify "
                               "equal.disp=TRUE, which assumes both groups "
                               "have the same dispersion, then the data "
                               "from two groups are combined and used as "
                               "replicates to estimate dispersion; or (2) "
                               "specify smoothing=TRUE, which uses the "
                               "smoothed means (methylation levels) to "
                               "estimate dispersions via a shrinkage "
                               "estimator. This smoothing procedure uses "
                               "data from neighboring CpG sites as "
                               "\"pseudo-replicate\" for estimating "
                               "biological variance. Default is TRUE"))
    dma_opt.add_argument("--pval_cutoff", "-pvc",
                         action="store",
                         type=float,
                         default=0.001,
                         required=False,
                         help=("A threshold of p-values for calling DMR. "
                               "Loci with p-values less than this "
                               "threshold will be picked and joint to form "
                               "the DMRs. See 'details' for more "
                               "information. Default is 0.001"))
    dma_opt.add_argument("--delta_cutoff", "-dc",
                         action="store",
                         type=float,
                         default=0.05,
                         required=False,
                         help=("A threshold for defining DMR. In DML "
                               "detection procedure, a hypothesis test "
                               "that the two groups means are equal is "
                               "conducted at each CpG site. Here if "
                               "'delta' is specified, the function will "
                               "compute the posterior probability that the "
                               "difference of the means are greater than "
                               "delta, and then construct DMR based on "
                               "that. This only works when the test "
                               "results are from 'DMLtest', which is for "
                               "two-group comparison. Default is 0.05"))
    dma_opt.add_argument("--pct_sig", "-pct",
                         action="store",
                         type=float,
                         default=0.5,
                         required=False,
                         help=("In all DMRs, the percentage of CG sites "
                               "with significant p-values (less than "
                               "p.threshold) must be greater than this "
                               "threshold. Default is 0.5. This is mainly "
                               "used for correcting the effects of merging "
                               "of nearby DMRs."))
    dma_opt.add_argument("--overwrite", "-ow",
                         action="store_true",
                         required=False,
                         help="If output files exist overwrite them")
    dma_opt.add_argument("--is_bed",
                         action="store_true",
                         required=False,
                         help="If input files are in bedmethyl format")
    args = parser.parse_args()

    main_dma(args)


if __name__ == '__main__':
    main()
