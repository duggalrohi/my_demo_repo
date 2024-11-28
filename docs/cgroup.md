
# Welcome to the MPI 
## Debug Errors

Source: 
Follow this implementation of [cgroups](https://hpc-syspros-basics.github.io/Advanced_Topics/Login_Node_Resource_Management/cgroups.html).

!!! example "Control Group Implementation"
  
    === "user.slice"

        ``` bash
        
        cat > /etc/systemd/system/user.slice <<EOW
        # /etc/systemd/system/user.slice
        # Source: https://hpc-syspros-basics.github.io/Advanced_Topics/Login_Node_Resource_Management/cgroups.html
        # 
        # CPUQuota = 100% # 4 cores * 100 * 0.25 
        #          = 100% 
        #     - to limit 1 core for each user 
        #       in a system with 4 cores total
        # Set MemoryHigh and MemoryMax as per 
        # requirement 
        # e.g., 1% = 17.7 MB verified inside a
        # TEST env
        # MemorySwapMax = 0% means no swap usage for users
        #  SPDX-License-Identifier: LGPL-2.1+
        #
        #  This file is part of systemd.
        #
        #  systemd is free software; you can redistribute it and/or modify it
        #  under the terms of the GNU Lesser General Public License as published by
        #  the Free Software Foundation; either version 2.1 of the License, or
        #  (at your option) any later version.

        [Unit]
        Description=User and Session Slice
        Documentation=man:systemd.special(7)
        Before=slices.target

        [Slice]
        CPUQuota=100%
        MemoryHigh=1%
        MemoryMax=1%
        MemorySwapMax=0%
        EOW
        ```

    === "user-.slice"

        ``` bash
        cat > /etc/systemd/system/user-.slice.d/10-defaults.conf <<EOW
        # /etc/systemd/system/user-.slice.d/10-defaults.conf
        #  SPDX-License-Identifier: LGPL-2.1+
        #
        #  This file is part of systemd.
        #
        #  systemd is free software; you can redistribute it and/or modify it
        #  under the terms of the GNU Lesser General Public License as published by
        #  the Free Software Foundation; either version 2.1 of the License, or
        #  (at your option) any later version.

        [Unit]
        Description=User Slice of UID %j
        After=systemd-user-sessions.service

        [Slice]
        TasksMax=80%
        CPUQuota=320%
        MemoryHigh=10M
        MemoryMax=11M
        MemorySwapMax=0G
        Swappiness=0M
        EOW

        ```


Reload systemctl daemon

``` bash 
systemctl daemon-reload
```

Now, the users will be placed in new cgroups with new limits.

To verify, 

``` bash
systemctl status user.slice

systemctl status user-0.status

```
