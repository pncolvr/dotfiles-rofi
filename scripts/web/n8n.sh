#!/usr/bin/env bash

WORKSPACE=$(echo "$0" | xargs realpath | xargs dirname | xargs dirname)/_common
source "$WORKSPACE"/utils.sh

# const items = document.querySelectorAll('#content > div > div > main > div > div > div._body_mbox7_130 > div > div > div._listItems_5203n_183 > div > div > div');
# const allItems = [];
#   const baseUrl = `http://${window.location.host}/workflow`;

#   items.forEach(item => {
#     const name = item.dataset.resourcename;
#     const id = item.dataset.resourceid;

#     if (name && id) {
#       allItems.push(`"${name}_${id}"="${baseUrl}/${id}"`);
#     }
#   });

#   const toCopy = allItems.join('\n');
#   console.log(toCopy);


links=$(realpath $(get_env_file $0))

"$WORKSPACE"/handle.sh "$links"
