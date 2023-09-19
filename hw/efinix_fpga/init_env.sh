# # This stuff will install efinity per machine, per project.
# # That would be a lot of wasted storage

# ENV=".env/$HOSTNAME"

# if [ ! -d "$ENV" ]; then
#     mkdir -p "$ENV"
# fi

# if [ ! -f "$ENV/efinity-2023.1.150-rhe-x64.tar.bz2" ]; then
#     scp 192.168.50.101:/export/scratch/efinity-2023.1.150-rhe-x64.tar.bz2 "$ENV"
# fi

# if [ ! -d "$ENV/efinity" ]; then
#     pv "$ENV/efinity-2023.1.150-rhe-x64.tar.bz2" | tar xj --directory "$ENV"
#     scp 192.168.50.101:/export/scratch/libffi.so.6 "$ENV/efinity/2023.1/lib/"
# fi

# source "$ENV/efinity/2023.1/bin/setup.sh"
# export PATH=$PATH:"$EFXPT_HOME/bin"

source $EFX_SETUP

# python -m venv .user_venv --system-site-packages
# . .user_venv/bin/activate

# pip install -r requirements.txt
