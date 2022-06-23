#!/bin/bash
set -e

: "${FATE_DIR:=/data/projects/fate}"



# cd worker_dir
BASEDIR=$FATE_DIR
cd "$BASEDIR"
WORKING_DIR=$(pwd)

# get version
source_dir=$(cd `dirname $0`; cd ../;cd ../;pwd)
cd ${source_dir}

cd ${WORKING_DIR}

version="$(grep -ioP "(?<=FATE=).+" "$FATE_DIR/fate.env")"

# set image PREFIX and TAG
# default PREFIX is federatedai
PREFIX="federatedai"
if [ -z "$TAG" ]; then
        TAG="${version}-release"
fi
BASE_TAG=${TAG}
source ${WORKING_DIR}/.env

# print build INFO
echo "[INFO] Build info"
echo "[INFO] Version: v"${version}
echo "[INFO] Image prefix is: "${PREFIX}
echo "[INFO] Image tag is: "${TAG}
echo "[INFO] Base image tag is: "${BASE_TAG}
echo "[INFO] source dir: "${source_dir}
echo "[INFO] Package dir is: "${WORKING_DIR}/catch/

package() {
        # cd ${WORKING_DIR}

        # [ -d ../package-build/build_docker.sh  ] && rm -rf ../package-build/build_docker.sh 
        # cp ../package-build/build.sh ../package-build/build_docker.sh 
        # sed -i '' 's#mvn clean package -DskipTests#docker run --rm -u $(id -u):$(id -g) -v ${source_dir}/fateboard:/data/projects/fate/fateboard --entrypoint="" maven:3.6-jdk-8 /bin/bash -c "cd /data/projects/fate/fateboard \&\& mvn clean package -DskipTests"#g'   build_docker.sh 
        #  sed -i '' 's#bash ./auto-packaging.sh#docker run --rm -u $(id -u):$(id -g) -v ${source_dir}/eggroll:/data/projects/fate/eggroll --entrypoint="" maven:3.6-jdk-8 /bin/bash -c "cd /data/projects/fate/eggroll/deploy \&\& bash auto-packaging.sh"#g' build_docker.sh 

        cp build_docker.sh $FATE_DIR/package-build/

        cd ${WORKING_DIR}
        # package all
        source ../package-build/build_docker.sh release all

        rm -rf ../package-build/build_docker.sh

        mkdir -p ${WORKING_DIR}/catch/
        cp -r ${package_dir}/* ${WORKING_DIR}/catch/
}

build_builder() {
    echo "Building builder"
    docker build -t federatedai/builder -f builder/Dockerfile docker/builder
    echo "Built builder"
}

check_fate_dir() {
    if [ ! -d "$FATE_DIR" ]; then
        echo "FATE_DIR ($FATE_DIR) does not exist"
        exit 1
    fi
}

build_fate() {
    echo "Building fate"
    docker run -v $FATE_DIR:$FATE_DIR federatedai/builder /bin/bash -c "cd $FATE_DIR && ./build.sh"
    echo "Built fate"
}

build_base_image() {
    echo "Building base image"
    docker build -t federatedai/base -f base/Dockerfile docker/base
    echo "Built base image"
}

build_model_image() {
    echo "Building model image"
    for model in $(ls -d docker/modules/*/); do
        model_name=$(basename $model)
        echo "Building $model_name"
        docker build -t federatedai/$model_name -f $model/Dockerfile docker/modules/$model_name
        echo "Built $model_name"
    done
    echo "Built model image"
}

images_push() {
    echo "Pushing images"
    for image in $(ls -d docker/modules/*/); do
        image_name=$(basename $image)
        echo "Pushing federatedai/$image_name"
        docker push federatedai/$model_name
        echo "Pushed federatedai/$image_name"
    done
    echo "Pushed images"
}

while getopts "hf:" opt; do
    case $opt in
        h)
            echo "Usage: ./build.sh [-h] [-f fate_dir]"
            echo "Options:"
            echo "  -h  Show this help message and exit"
            echo "  -f  Path to fate directory"
            exit 0
            ;;
        f)
            FATE_DIR=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
