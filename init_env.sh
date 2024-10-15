# # This stuff will install efinity per machine, per project.
# # That would be a lot of wasted storage

# ENV=".env/$HOSTNAME"

export REPO_TOP=$(git rev-parse --show-toplevel)
export KICAD7_SYMBOL_DIR=$REPO_TOP/hw/kicad_library/symbols
export KICAD7_3DMODEL_DIR=$REPO_TOP/hw/kicad_library/3dmodels
export KICAD7_FOOTPRINT_DIR=$REPO_TOP/hw/kicad_library/footprints

#module load efinity/2023.1
module load verilator
module load gtkwave/3.3_gtk3

python3.12 -m venv .user_venv
. .user_venv/bin/activate

pip install -r requirements.txt
