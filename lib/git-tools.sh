# Initialized git repository in the specified
# folder.
gitInit() {
  path=$1
  cd $path || exit 1
  if [[ -e .git ]]
  then
    echo "Git already initialized in [$PWD]"
    exit 1
  fi
  git init
  git add .
  git commit -m "Initial commit"
}
