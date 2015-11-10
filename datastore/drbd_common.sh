#!/bin/bash

# Return newline separated list of nodes that are assigned to a resource.
get_res_nodes () {
      echo "$(drbdmanage assignments -m --resources $1 | awk -F',' '{ print $1 }')"
}

# Return single node with a resource assigned to it.
get_assignment_node () {

  echo $(get_res_nodes $1 | awk -F' ' '{ print $1 }' )

}

# Check if resource is in connected and deployed on a single node.
is_res_deployed () {

  NODE_STATE="$(drbdmanage assignments -m --resources $1 --nodes $2 | awk -F',' '{ print $4, $5 }')"

  if [ "$NODE_STATE" = "connect|deploy connect|deploy" ]; then
    echo 0
  else
    echo 1
  fi

}

# Wait until resource is deployed and connected on a single node.
wait_res_deployed () {

  RETRY_LIMIT=10

  until [ $(is_res_deployed $1 $2) -eq 0 ]; do
    sleep 1
    if [ RETRY_LIMIT -lt 1 ]; then
      exit -1
    fi
    ((RETRY_LIMIT--))
  done

  echo 0

}


# Returns path to device node for a resource.
get_device_for_res () {

  DRBD_MINOR="$(drbdmanage v -m -R "$1" | awk -F',' '{ print $6 }')"

  echo "/dev/$DRBD_MINOR_PREFIX$DRBD_MINOR"

}

