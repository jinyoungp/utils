#!/bin/bash
# https://github.com/jinyoungp/utils.git
# Jinyoung Park <jinyoungp@nvidia.com>

work_cmd_echo()
{
	cmd="${@}"
	echo "[`date`][CMD] ${cmd}"
	if [[ "${cmd}" =~ "source " ]] || [[ "${cmd}" =~ "cd " ]] || [[ "${cmd}" =~ "pushd " ]] || [[ "${cmd}" =~ "popd" ]] || [[ "${cmd}" =~ "setpaths " ]] || [[ "${cmd}" =~ "choosecombo " ]]; then
		${cmd}
	elif [[ "${cmd}" =~ "git fetch --all " ]]; then
		eval ${cmd}
	elif [[ "${cmd}" =~ "repo forall -c " ]]; then
		cmd=
		argc=$#
		for ((i=1 ; i < ${argc} ; i++)); do
			cmd="${cmd} ${1}"
			shift
		done
		${cmd} "${1}"
	else
		${cmd}
	fi

	if [ ${?} -ne 0 ]; then
		exit ${rc}
	fi
}

work_repo_search_patch_work()
{
	if ! [ -d "./.repo/manifests" ]; then
		echo "[ERROR] Couldn't find .repo/manifests"
		return 1
	fi

	work_cmd_echo repo forall -c "if [ -d patch_work ]; then pwd; git branch; echo '-> patch_work'; ls patch_work; echo ''; fi;"

	return 0;
}

work_repo_no_fetch_checkout_branch()
{
	if ! [ -d "./.repo/manifests" ]; then
		echo "[ERROR] Couldn't find .repo/manifests"
		return 1
	fi

	if ! [ -n "$BRANCH" ]; then
		echo "[ERROR] No BRANCH. Please set BRANCH variable."
		return 1
	fi

	work_cmd_echo pushd .repo/manifests
	work_cmd_echo git pull
	work_cmd_echo popd

	work_cmd_echo repo forall -c "if [ -d patch_work ]; then pwd; git branch; echo '-> patch_work'; ls patch_work; echo ''; else git reset -q --hard; git checkout m/${BRANCH} >/dev/null 2>&1; git branch -D ${BRANCH} >/dev/null 2>&1; git checkout -q -t m/${BRANCH} >/dev/null 2>&1; git checkout -q ${BRANCH} >/dev/null 2>&1; git merge m/${BRANCH} >/dev/null 2>&1; fi;"

	return 0
}

work_repo_fetch_checkout_branch()
{
	if ! [ -d "./.repo/manifests" ]; then
		echo "[ERROR] Couldn't find .repo/manifests"
		return 1
	fi

	if ! [ -n "$BRANCH" ]; then
		echo "[ERROR] No BRANCH. Please set BRANCH variable."
		return 1
	fi

	work_cmd_echo pushd .repo/manifests
	work_cmd_echo git pull
	work_cmd_echo popd

	work_cmd_echo repo forall -c "git fetch -q --all; if [ -d patch_work ]; then pwd; git branch; echo '-> patch_work'; ls patch_work; echo ''; else git reset -q --hard; git checkout m/${BRANCH} >/dev/null 2>&1; git branch -D ${BRANCH} >/dev/null 2>&1; git checkout -q -t m/${BRANCH} >/dev/null 2>&1; git checkout -q ${BRANCH} >/dev/null 2>&1; git merge m/${BRANCH} >/dev/null 2>&1; fi;"

	return 0
}

work_repo_diff_branch()
{
	if ! [ -n "$BRANCH" ]; then
		echo "[ERROR] No BRANCH. Please set BRANCH variable."
		return 1
	fi

	work_cmd_echo repo forall -c "pwd; if [ -d patch_work ]; then git branch; echo '-> patch_work'; ls patch_work; echo ''; fi; git diff --stat m/${BRANCH};"
}

work_repo_manifest()
{
	if ! [ -d "./.repo/manifests" ]; then
		echo "[ERROR] Couldn't find .repo/manifests"
		return 1
	fi

	local curpath=`pwd`
	local dirname=`dirname ${curpath}`
	local osname=`basename ${curpath}`
	local codeline=`basename ${dirname}`
	work_cmd_echo repo manifest -r -o ${codeline}-${osname}-manifest-`date +%Y%m%d_%H%M%S`.xml
}

work_repo_sync()
{
	if ! [ -d "./.repo/manifests" ]; then
		echo "[ERROR] Couldn't find .repo/manifests"
		return 1
	fi

	work_cmd_echo repo sync $@
	work_repo_manifest
}
