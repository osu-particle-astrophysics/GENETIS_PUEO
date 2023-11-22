import argparse

def parse_args():
    '''Parse the command line arguments'''
    parser = argparse.ArgumentParser()
    parser.add_argument('jobs_running', type=int, 
                        help='count of all jobs currently running')
    parser.add_argument('gpu_jobs_left', type=int, 
                        help='number of GPU jobs left')
    parser.add_argument('xfkeys', type=int, 
                        help='number of XF keys used in the run')
    parser.add_argument('nnt', type=int, 
                        help='Total number of neutrinos per antenna')
    parser.add_argument('max_jobs', type=int, 
                        help='Maximum number of concurrent jobs')
    args = parser.parse_args()
    return args


def main(args):
    '''Calculate the number of neutrinos per job and the number of jobs'''
    if args.gpu_jobs_left > args.xfkeys:
        num_jobs = int((args.max_jobs - args.xfkeys) / args.xfkeys)
    else:
        # If we're able to run more jobs for the last set of simulations,
        # we want to run as many as possible
        case1 = (args.max_jobs - args.jobs_running) / args.gpu_jobs_left
        case2 = (args.max_jobs - args.xfkeys) / args.xfkeys
        
        num_jobs = int(max(case1, case2))
    nnt_per_job = int(args.nnt / num_jobs / 40)
    
    # The bash script will parse the print statement into a variable
    print(f"{nnt_per_job},{num_jobs}")

    
if __name__ == '__main__':
    args = parse_args()
    main(args)
    