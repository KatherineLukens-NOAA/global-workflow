#!/bin/sh

#BSUB -J jgfs_gempak_upapgif_00
#BSUB -o /gpfs/dell2/ptmp/Boi.Vuong/output/gfs_gempak_upapgif_00.o%J
#BSUB -e /gpfs/dell2/ptmp/Boi.Vuong/output/gfs_gempak_upapgif_00.o%J
#BSUB -q debug
#BSUB -n 1                      # number of tasks
#BSUB -R span[ptile=1]          # 1 task per node
#BSUB -cwd /gpfs/dell2/ptmp/Boi.Vuong/output
#BSUB -W 00:30
#BSUB -P GFS-T2O
#BSUB -R affinity[core(1):distribute=balance]

export KMP_AFFINITY=disabled

export PDY=`date -u +%Y%m%d`
export PDY=20180824

export PDY1=`expr $PDY - 1`

export cyc=00
export cycle=t${cyc}z

set -xa
export PS4='$SECONDS + '
date

####################################
##  Load the GRIB Utilities module
#####################################
module load EnvVars/1.0.2
module load ips/18.0.1.163
module load CFP/2.0.1
module load impi/18.0.1
module load lsf/10.1
module load prod_util/1.1.0
module load prod_envir/1.0.2
#
#   This is a test version of GRIB_UTIL.v1.1.0 on DELL
#
module load dev/grib_util/1.1.0
#
#   This is a test version of UTIL_SHARED.v1.0.8 on DELL
#
module load dev/util_shared/1.0.8
module list
###########################################
# Now set up GEMPAK/NTRANS environment
###########################################
module use -a /gpfs/dell1/nco/ops/nwpara/modulefiles/
module load gempak/7.3.1
module list

##############################################
# Define COM, COMOUTwmo, COMIN  directories
##############################################

# set envir=prod or para to test with data in prod or para
 export envir=para
# export envir=prod

export SENDCOM=YES
export KEEPDATA=YES
export job=gfs_gempak_upapgif_${cyc}
export pid=${pid:-$$}
export jobid=${job}.${pid}

# Set FAKE DBNET for testing
export SENDDBN=YES
export DBNROOT=/gpfs/hps/nco/ops/nwprod/prod_util.v1.0.24/fakedbn

export DATAROOT=/gpfs/dell2/ptmp/Boi.Vuong/output
export NWROOT=/gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/git
export COMROOT2=/gpfs/dell2/ptmp/Boi.Vuong/com

mkdir -m 775 -p ${COMROOT2} ${COMROOT2}/logs ${COMROOT2}/logs/jlogfiles
export jlogfile=${COMROOT2}/logs/jlogfiles/jlogfile.${jobid}

#############################################################
# Specify versions
#############################################################
export gfs_ver=v15.0.0

##########################################################
# obtain unique process id (pid) and make temp directory
##########################################################
export DATA=${DATA:-${DATAROOT}/${jobid}}
mkdir -p $DATA
cd $DATA

################################
# Set up the HOME directory
################################
export HOMEgfs=${HOMEgfs:-${NWROOT}/gfs.${gfs_ver}}
export EXECgfs=${EXECgfs:-$HOMEgfs/exec}
export PARMgfs=${PARMgfs:-$HOMEgfs/parm}
export FIXgfs=${FIXgfs:-$HOMEgfs/gempak/fix}
export USHgfs=${USHgfs:-$HOMEgfs/gempak/ush}
export SRCgfs=${SRCgfs:-$HOMEgfs/scripts}

######################################
# Set up the GEMPAK directory
#######################################
export HOMEgempak=${HOMEgempak:-${NWROOTp1}/gempak}
export FIXgempak=${FIXgempak:-$HOMEgempak/fix}
export USHgempak=${USHgempak:-$HOMEgempak/ush}

###################################
# Specify NET and RUN Name and model
####################################
export NET=${NET:-gfs}
export RUN=${RUN:-gfs}
export model=${model:-gfs}
export MODEL=GFS

##############################################
# Define COM directories
##############################################
if [ $envir = "prod" ] ; then
#  This setting is for testing with GFS (production)
  export COMIN=/gpfs/hps/nco/ops/com/nawips/prod/${RUN}.${PDY}            ### NCO PROD
  export COMINgfs=/gpfs/hps/nco/ops/com/nawips/prod/${RUN}.${PDY}         ### NCO PROD
else
#  export COMIN=/gpfs/dell3/ptmp/emc.glopara/ROTDIRS/prfv3rt1/gfs.${PDY}/${cyc}/nawips ### EMC PARA Realtime on DELL
#  export COMINgfs=/gpfs/dell3/ptmp/emc.glopara/ROTDIRS/prfv3rt1/gfs.${PDY}/${cyc} ### EMC PARA Realtime on DELL

  export COMIN=/gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/git/${NET}/${envir}/${RUN}.${PDY}/${cyc}/nawips   ### Boi PARA
  export COMINgfs=/gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/git/${NET}/${envir}/${RUN}.${PDY}/${cyc}
fi

export COMOUT=${COMROOT2}/${NET}/${envir}/${RUN}.${PDY}/${cyc}
export COMOUTwmo=${COMOUTwmo:-${COMOUT}/wmo}

if [ $SENDCOM = YES ] ; then
  mkdir -m 775 -p $COMOUT $COMOUTwmo
fi

#############################################
# run the GFS job
#############################################
sh $HOMEgfs/jobs/JGFS_GEMPAK_NCDC_UPAPGIF