# Count the number of jobs from string of format:
# 28178971_1 28178971_2 28178971_[3-50]
import argparse
import re

def expand_array_job(job_id):
    '''expand 28178971_[3-50] to 28178971_3, 28178971_4, ..., 28178971_50'''
    if re.match(r'\d+_\[\d+-\d+\]$', job_id):
        prefix, range_str = job_id.split('_')
        start, end = map(int, range_str[1:-1].split('-'))
        return [f"{prefix}_{i}" for i in range(start, end + 1)]
    else:
        return [job_id]


def read_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('job_ids', type=str, help='Count the number of jobs from the squeue string')
    args = parser.parse_args()
    return args


def main(args):
    '''Count the number of jobs from the squeue string'''
    jobs = args.job_ids.split()
    job_count = 0
    for job in jobs:
        job_count += len(expand_array_job(job))
    print(job_count)
    
    
if __name__ == '__main__':
    args = read_args()
    main(args)