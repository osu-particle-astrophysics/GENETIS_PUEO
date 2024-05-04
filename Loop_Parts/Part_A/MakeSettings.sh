#### Create the GA's settings.yaml file from bash variables ####
WorkingDir=$1
RunName=$2
source $WorkingDir/Run_Outputs/$RunName/setup.sh

cd $WorkingDir/Run_Outputs/$RunName

# Create the settings.yaml file
{
echo '# General'
echo 'a_type: "horn"'
echo 'npop: '$NPOP
echo 'n_gen: '$TotalGens
echo 'steady_state: '$SteadyState
echo 'replacement_method: "'$REPLACEMENT'"'
echo 'forced_diversity: '$ForcedDiversity
echo 'verbose: True'
echo 'save_all_files: True'
echo 'test_loop: False'
echo 'run_dir: "'$WorkingDir'/Run_Outputs/'$RunName'"'

echo '# Operators'
echo 'crossover_rate: '$CROSSOVER
echo 'mutation_rate: '$MUTATION
echo 'reproduction_rate: '$REPRODUCTION
echo 'sigma: '$SIGMA

echo '# Selection'
echo 'tournament_rate: '$TOURNAMENT
echo 'roulette_rate: '$ROULETTE
echo 'rank_rate: '$RANK
echo 'tournament_size: 0.07'
} > settings.yaml
