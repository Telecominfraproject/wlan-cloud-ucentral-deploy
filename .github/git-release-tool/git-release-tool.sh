#!/bin/bash
set -e

# git-release-tool
# This script is used to manually cut releases for the TIP OpenWIFI CloudSDK 2.x repos
# For other details, see "usage" function or simply run script

# Constants
export PAGER=cat

# Internal vars
LOG_VERBOSITY_NUMBER=0
REPO_TAGS_ARRAY=()

# Helper functions
## Logging functions
log_notice() {
  echo "[Notice] "$1
}

log_error() {
  if [[ "$LOG_VERBOSITY_NUMBER" -ge 0 ]]; then
    echo "[Error] "$1 >/dev/stderr
  fi
}

log_info() {
  if [[ "$LOG_VERBOSITY_NUMBER" -ge 1 ]]; then
    echo "[Info] "$1
  fi
}

log_debug() {
  if [[ "$LOG_VERBOSITY_NUMBER" -ge 2 ]]; then
    echo "[Debug] "$1
  fi
}

## Usage info
usage() {
  echo
  log_notice "$0 - script to cut releases for TIP OpenWIFI CloudSDK 2.x repos"
  log_notice
  log_notice "This script requires configuration file 'repositories.yaml' near the script and list of environment variables to work"
  log_notice
  log_notice "repositories.yaml file format:"
  echo "deploy_repo_url: git@github.com:Telecominfraproject/wlan-cloud-ucentral-deploy.git # modify if repo name changes"
  echo "repositories:"
  echo "  - name: owgw-ui # should be the same as in image repository in helm values (i.e. tip-tip-wlan-cloud-ucentral.jfrog.io/owgw-ui)"
  echo "    url: git@github.com:Telecominfraproject/wlan-cloud-owprov-ui.git # it's up to you to use SSH or HTTPS format and setup credentials for push/pull"
  echo "    docker_compose_name: OWPROVUI # name of environment variable in docker-compose .env file containing image tag for the service"
  log_notice
  log_notice "List of required environment variables:"
  log_notice "- RELEASE_VERSION - release version that should be applied to repositories. Should comply release nameing policy (valid example - 'v2.0.0' or 'v2.0.1')"
  log_notice "- TAG_TYPE - type of tag that should be created for release (supported values - RC / FINAL)"
  log_notice "- GIT_PUSH_CONFIRMED - confirmation that any changes should be pushed to git (dry-run if unset, set to 'true' to enable)"
  log_notice
  log_notice "You may increase log verbosity by setting environment variable LOG_VERBOSITY to required level (ERROR/INFO/DEBUG)"
#
}

## Setting functions
set_log_verbosity_number() {
  # Log verbosity levels:
  # 0 - ERROR
  # 1 - INFO
  # 2 - DEBUG
  case $LOG_VERBOSITY in
    ERROR )
      LOG_VERBOSITY_NUMBER=0
    ;;
    INFO )
      LOG_VERBOSITY_NUMBER=1
    ;;
    DEBUG )
      LOG_VERBOSITY_NUMBER=2
    ;;
    * )
      log_notice "Setting LOG_VERBOSITY to INFO by default"
      LOG_VERBOSITY_NUMBER=1
    ;;
  esac
}

## Git manipulation functions
modify_deploy_repo_values() {
  NEW_RELEASE_TAG=$1
  log_debug "NEW_RELEASE_TAG - $NEW_RELEASE_TAG"
  REPOSITORIES_AMOUNT=$(cat ../release.repositories.yaml | yq ".repositories[].name" -r | wc -l)
  for REPO_INDEX in $(seq 0 $(expr $REPOSITORIES_AMOUNT - 1)); do
    REPO_URL=$(cat ../release.repositories.yaml | yq ".repositories[$REPO_INDEX].url" -r)
    REPO_NAME_SUFFIXED=$(echo $REPO_URL | awk -F '/' '{print $NF}')
    REPO_NAME_WITHOUT_SUFFIX=${REPO_NAME_SUFFIXED%.git}
    REPO_DOCKER_COMPOSE_NAME=$(cat ../release.repositories.yaml | yq ".repositories[$REPO_INDEX].docker_compose_name" -r)
    SERVICE_TAG="${REPO_TAGS_ARRAY[$REPO_INDEX]}"
    log_debug "REPO_NAME_WITHOUT_SUFFIX - $REPO_NAME_WITHOUT_SUFFIX"
    sed "s/$REPO_DOCKER_COMPOSE_NAME=.*/$REPO_DOCKER_COMPOSE_NAME=$SERVICE_TAG/" -i docker-compose/.env
    sed "s/$REPO_DOCKER_COMPOSE_NAME=.*/$REPO_DOCKER_COMPOSE_NAME=$SERVICE_TAG/" -i docker-compose/.env.letsencrypt
    sed "s/$REPO_DOCKER_COMPOSE_NAME=.*/$REPO_DOCKER_COMPOSE_NAME=$SERVICE_TAG/" -i docker-compose/.env.selfsigned
    sed "/${REPO_NAME_WITHOUT_SUFFIX#*/}@/s/ref=.*/ref=$SERVICE_TAG\"/g" -i chart/Chart.yaml
    sed "/repository: tip-tip-wlan-cloud-ucentral.jfrog.io\/clustersysteminfo/!b;n;s/tag: .*/tag: $NEW_RELEASE_TAG/" -i chart/values.yaml
  done
  LATEST_RELEASE_TAG=$(git tag | grep $RELEASE_VERSION | tail -1)
  if [[ "$(git diff | wc -l)" -eq "0" ]] && [[ "$(git diff $LATEST_RELEASE_TAG)" -eq "0" ]]; then
    log_info "No changes in microservices and since the latest tag are found, new release is not required"
  else
    sed 's/^version: .*/version: '${NEW_RELEASE_TAG#v}'/' chart/Chart.yaml -i
  fi
  git diff
}

modify_values() {
  NEW_RELEASE_TAG=$1
  if [[ "$(basename $PWD)" == "deploy" ]]; then
    modify_deploy_repo_values $NEW_RELEASE_TAG
  else
    sed "/repository: tip-tip-wlan-cloud-ucentral.jfrog.io\/$(basename $PWD)/!b;n;s/tag: .*/tag: $NEW_RELEASE_TAG/" -i helm/values.yaml
  fi
  if [[ "$LOG_VERBOSITY_NUMBER" -ge 2 ]]; then
    log_debug "Diff to me commited:"
    git diff
  fi
  git add .
  git commit -m"Chg: update image tag in helm values to $NEW_RELEASE_TAG"
}

push_changes() {
  CURRENT_RELEASE=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$GIT_PUSH_CONFIRMED" == "true" ]]; then
    log_info "Pushing branch changes and tags:"
    git push -u origin $CURRENT_RELEASE
    git push --tags
  else
    log_info "Skipping pushing of branch and tags due to GIT_PUSH_CONFIRMED not being set to 'true'"
  fi
}

create_tag() {
  TAG_TYPE_LOWERED=$(echo $TAG_TYPE | tr '[:upper:]' '[:lower:]')
  if [[ "$TAG_TYPE_LOWERED" == "final" ]]; then
    log_debug "Creating final tag"
    modify_values $RELEASE_VERSION
    git tag $RELEASE_VERSION
    push_changes
    REPO_TAGS_ARRAY+=($RELEASE_VERSION)
  else
    log_debug "Checking if there are tags in the current release branch"
    LATEST_RELEASE_TAG=$(git tag | grep $RELEASE_VERSION | tail -1)
    log_debug "Latest release tag found - '$LATEST_RELEASE_TAG'"
    if [[ -z "$LATEST_RELEASE_TAG" ]]; then
      log_info "There are no tags in the release branch, creating the first one"
      NEW_RELEASE_TAG=$RELEASE_VERSION-RC1
      log_debug "New tag - $NEW_RELEASE_TAG"
      modify_values $NEW_RELEASE_TAG
      git tag $NEW_RELEASE_TAG
      push_changes
      REPO_TAGS_ARRAY+=($NEW_RELEASE_TAG)
    else
      if [[ "$(basename $PWD)" == "deploy" ]]; then
        NEW_RC=$(echo $LATEST_RELEASE_TAG | awk -F 'RC' '{print $2}')
        NEW_RC=$(expr $NEW_RC + 1)
        log_debug "New RC to create - $NEW_RC"
        NEW_RELEASE_TAG=$RELEASE_VERSION-RC$NEW_RC
        modify_deploy_repo_values $NEW_RELEASE_TAG
        if [[ "v$(cat chart/Chart.yaml | yq '.version' -r)" == "$NEW_RELEASE_TAG" ]]; then
          git add .
          git commit -m"Chg: update image tag in helm values to $NEW_RELEASE_TAG"
          git tag $NEW_RELEASE_TAG
          push_changes
          log_info "New tag $NEW_RELEASE_TAG was created and pushed"
          REPO_TAGS_ARRAY+=($NEW_RELEASE_TAG)
        else
          log_info "New tag for deploy repo is not required, saving existing one ($LATEST_RELEASE_TAG)"
          REPO_TAGS_ARRAY+=($LATEST_RELEASE_TAG)
        fi
      else
        log_debug "Checking if the latest tag is on the latest commit"
        LATEST_REVISION=$(git rev-parse HEAD)
        LATEST_RELEASE_TAG_REVISION=$(git rev-parse $LATEST_RELEASE_TAG)
        log_debug "Latest revision ----- $LATEST_REVISION"
        log_debug "Latest tag revision - $LATEST_RELEASE_TAG_REVISION"
        if [[ "$LATEST_REVISION" == "$LATEST_RELEASE_TAG_REVISION" ]]; then
          log_info "Existing tag $LATEST_RELEASE_TAG is pointing to the latest commit in the release branch"
          REPO_TAGS_ARRAY+=($LATEST_RELEASE_TAG)
        else
          NEW_RC=$(echo $LATEST_RELEASE_TAG | awk -F 'RC' '{print $2}')
          NEW_RC=$(expr $NEW_RC + 1)
          log_debug "New RC to create - $NEW_RC"
          NEW_RELEASE_TAG=$RELEASE_VERSION-RC$NEW_RC
          modify_values $NEW_RELEASE_TAG
          git tag $NEW_RELEASE_TAG
          push_changes
          log_info "New tag $NEW_RELEASE_TAG was created and pushed"
          REPO_TAGS_ARRAY+=($NEW_RELEASE_TAG)
        fi
      fi
    fi
  fi
}

check_final_tag() {
  log_debug "Amount of final tags found - $(git tag | grep -x $RELEASE_VERSION | wc -l)"
  if [[ "$(git tag | grep -x $RELEASE_VERSION | wc -l)" -gt "0" ]]; then
    log_error "Final tag $RELEASE_VERSION already exists in release branch"
    exit 1
  fi
}

check_git_tags() {
  if [[ "${#REPO_TAGS_ARRAY[@]}" -eq "0" ]] && [[ "$(basename $PWD)" == "deploy" ]]; then
    log_info "This deploy clone run is required to get repositories tied to the release, we will make changes later."
  else
    RELEASE_TAGS_AMOUNT=$(git tag | grep $RELEASE_VERSION | wc -l)
    log_info "Checking if there are any tags for current version ($RELEASE_VERSION)"
    log_debug "Amount of tags linked with the release - $RELEASE_TAGS_AMOUNT"
    if [[ "$RELEASE_TAGS_AMOUNT" -gt "0" ]]; then
      log_info "Tags for release $RELEASE_VERSION are found, checking if final tag exist"
      check_final_tag
      create_tag
    else
      log_info "No tags found for current version, checking if there are any tags for release branch ($RELEASE_BRANCH_VERSION_BASE)"
      RELEASE_BRANCH_TAGS_AMOUNT=$(git tag | grep $RELEASE_BRANCH_VERSION_BASE | wc -l)
      log_debug "Amount of tags linked with the release branch - $RELEASE_BRANCH_TAGS_AMOUNT"
      if [[ "$RELEASE_BRANCH_TAGS_AMOUNT" -gt "0" ]]; then
        log_info "Tags for $RELEASE_BRANCH_VERSION_BASE are found, finding the latest one"
        RELEASE_BRANCH_TAG_FINAL=$(git tag | grep $RELEASE_BRANCH_VERSION_BASE | grep -v 'RC' | tail -1)
        if [[ ! -z "$RELEASE_BRANCH_TAG_FINAL" ]]; then
          RELEASE_BRANCH_TAG=$RELEASE_BRANCH_TAG_FINAL
        else
          RELEASE_BRANCH_TAG=$(git tag | grep $RELEASE_BRANCH_VERSION_BASE | tail -1)
        fi
        log_info "Latest release tag in $RELEASE_BRANCH_VERSION_BASE - $RELEASE_BRANCH_TAG. Checking if there are changes since then"
        DIFF_LINES_AMOUNT=$(git diff $RELEASE_BRANCH_TAG | wc -l)
        if [[ "$DIFF_LINES_AMOUNT" -eq "0" ]]; then
          log_info "No changes found since the latest release tag ($RELEASE_BRANCH_TAG), using it for new version"
          REPO_TAGS_ARRAY+=($RELEASE_BRANCH_TAG)
        else
          log_info "Changes are found in the branch, creating a new tag"
          create_tag
        fi
      else
        log_info "Tags for $RELEASE_BRANCH_VERSION_BASE not found, creating new one"
        create_tag
      fi
    fi
  fi
}

check_release_branch() {
  RELEASE_BRANCH=$1
  git checkout $RELEASE_BRANCH -q
  check_git_tags
}

create_release_branch() {
  git checkout -b release/$RELEASE_BRANCH_VERSION -q
  check_release_branch release/$RELEASE_BRANCH_VERSION
}

check_if_release_branch_required() {
  LATEST_RELEASE_BRANCH=$(git branch -r | grep 'release/' | tail -1 | xargs)
  log_debug "Latest release branch available - $LATEST_RELEASE_BRANCH"
  if [[ -z "$LATEST_RELEASE_BRANCH" ]]; then
    log_info "Could not find a single release branch, creating it"
    create_release_branch $RELEASE_BRANCH_VERSION
  else
    LAST_RELEASE_DIFF_LINES_AMOUNT=$(git diff $LATEST_RELEASE_BRANCH ':(exclude)helm/values.yaml' | wc -l)
    if [[ "$LAST_RELEASE_DIFF_LINES_AMOUNT" -eq "0" ]]; then
      log_info "There are no changes in project since the latest release branch $LATEST_RELEASE_BRANCH so we will use tag from it"
      LATEST_RELEASE=$(echo $LATEST_RELEASE_BRANCH | awk -F 'origin/release/' '{print $2}')
      LATEST_RELEASE_BASE=$(echo $LATEST_RELEASE | cut -f 1,2 -d '.')
      LATEST_RELEASE_TAG_FINAL=$(git tag | grep $LATEST_RELEASE_BASE | grep -v 'RC' | tail -1)
      if [[ ! -z "$LATEST_RELEASE_TAG_FINAL" ]]; then
        LATEST_RELEASE_TAG=$LATEST_RELEASE_TAG_FINAL
      else
        LATEST_RELEASE=$(git tag | grep $LATEST_RELEASE_BASE | tail -1)
      fi
      log_debug "Latest release - $LATEST_RELEASE"
      log_debug "Latest release base - $LATEST_RELEASE_BASE"
      log_debug "Latest release tag - $LATEST_RELEASE_TAG"
      if [[ -z "$LATEST_RELEASE_TAG" ]]; then
        log_info "Could not find any tags for $LATEST_RELEASE release, creating it"
        check_release_branch $LATEST_RELEASE
      else
        log_info "Latest release tag found - $LATEST_RELEASE_TAG"
        REPO_TAGS_ARRAY+=($LATEST_RELEASE_TAG)
      fi 
    else
      log_info "New release branch for $RELEASE_BRANCH_VERSION is required, creating it"
      create_release_branch $RELEASE_BRANCH_VERSION
    fi
  fi
}

get_release_branch_version() {
  RELEASE_BRANCH_VERSION_BASE=$(echo $RELEASE_VERSION | cut -f 1,2 -d '.')
  RELEASE_BRANCH_VERSION="$RELEASE_BRANCH_VERSION_BASE.0"
  if [[ "$RELEASE_BRANCH_VERSION" != "$RELEASE_VERSION" ]]; then
    log_info "Minor release version ($RELEASE_VERSION) deployment is detected, work will be checked in branch for $RELEASE_BRANCH_VERSION"
  fi
}

create_repo_version() {
  CWD=$PWD
  REPO_NAME=$1
  REPO_URL=$2
  rm -rf $REPO_NAME
  git clone -q $REPO_URL $REPO_NAME
  cd $REPO_NAME
  get_release_branch_version
  log_debug "Release branch version - $RELEASE_BRANCH_VERSION"
  DEFAULT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  RELEASE_BRANCH=$(git branch -r | grep $RELEASE_BRANCH_VERSION | awk -F 'origin/' '{print $2}' | xargs)
  log_debug "Release branch to check - '$RELEASE_BRANCH'"
  if [[ ! -z "$RELEASE_BRANCH" ]]; then
    log_info "Release branch $RELEASE_BRANCH exists in the repository, checking if it has tags"
    check_release_branch $RELEASE_BRANCH
  else
    log_info "Release branch does not exists in the repository, checking if we need to create it"
    check_if_release_branch_required $DEFAULT_BRANCH
  fi
  log_info "Release commit info:"
  git show
  cd $CWD
}

# Log level setup
set_log_verbosity_number

# Check system requirements
if ! command -v yq &> /dev/null; then
    log_error "Command yq could not be found"
    usage
    exit 2
fi
if ! command -v sed &> /dev/null; then
    log_error "Command sed could not be found"
    usage
    exit 2
fi
if ! command -v helm &> /dev/null; then
    log_error "Command helm could not be found"
    usage
    exit 2
fi
if [[ "$(helm plugin list | grep -wP '(helm-git|diff)' | wc -l)" -ne "2" ]]; then
    log_error "Helm plugins (helm-git and/or diff) are missing"
    usage
    exit 2
fi

# Check variables
log_debug "Release version: ${RELEASE_VERSION}"
[ -z ${RELEASE_VERSION+x} ] && echo "RELEASE_VERSION is unset" && usage && exit 3
echo "${RELEASE_VERSION}" | grep -xP "v(\d)+\.(\d)+\.\d+" >/dev/null || (log_error "RELEASE_VERSION is not in the right notation (correct example - v2.2.0 or v2.2.2)" && usage && exit 3)
log_debug "Tag type: ${TAG_TYPE}"
[ -z ${TAG_TYPE+x} ] && echo "TAG_TYPE is unset" && usage && exit 3
echo "${TAG_TYPE}" | tr '[:upper:]' '[:lower:]' | grep -xP "(rc|final)" >/dev/null || (log_error "TAG_TYPE is not in the supported values ('rc' or 'final', case insensitive)" && usage && exit 3)

# Main body
DEPLOY_REPO_URL=$(cat repositories.yaml | yq ".deploy_repo_url" -r)
log_debug "DEPLOY_REPO_URL - $DEPLOY_REPO_URL"

log_info "First we need to get repository list for tied deployment version"
create_repo_version "deploy" $DEPLOY_REPO_URL
cp deploy/.github/git-release-tool/repositories.yaml release.repositories.yaml
rm -rf deploy

log_info "Checking repositories"
REPOSITORIES_AMOUNT=$(cat release.repositories.yaml | yq ".repositories[].name" -r | wc -l)
log_info "Found $REPOSITORIES_AMOUNT repos to process"
for REPO_INDEX in $(seq 0 $(expr $REPOSITORIES_AMOUNT - 1)); do
  echo
  REPO_NAME=$(cat release.repositories.yaml | yq ".repositories[$REPO_INDEX].name" -r)
  REPO_URL=$(cat release.repositories.yaml | yq ".repositories[$REPO_INDEX].url" -r)
  REPO_DOCKER_COMPOSE_NAME=$(cat release.repositories.yaml | yq ".repositories[$REPO_INDEX].docker_compose_name" -r)
  log_debug "REPO_NAME - $REPO_NAME"
  log_debug "REPO_URL - $REPO_URL"
  log_debug "REPO_DOCKER_COMPOSE_NAME - $REPO_DOCKER_COMPOSE_NAME"
  log_info "Processing repository '$REPO_NAME'"
  create_repo_version $REPO_NAME $REPO_URL
  rm -rf $REPO_NAME
done
log_debug "Tags per project: ${REPO_TAGS_ARRAY[*]}"

echo
log_info "Preparing changes in deploy repo"
create_repo_version "deploy" $DEPLOY_REPO_URL

echo
log_info "Services versions:"
for REPO_INDEX in $(seq 0 $(expr $REPOSITORIES_AMOUNT - 1)); do
  REPO_NAME=$(cat release.repositories.yaml | yq ".repositories[$REPO_INDEX].name" -r)
  log_info "- $REPO_NAME - ${REPO_TAGS_ARRAY[$REPO_INDEX]}"
done
log_info "Deployment repo version - ${REPO_TAGS_ARRAY[-1]}"
rm release.repositories.yaml
if [[ "$GIT_PUSH_CONFIRMED" != "true" ]]; then
  log_info "To apply changes described above, set GIT_PUSH_CONFIRMED to 'true' and rerun this script"
fi
