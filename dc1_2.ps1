﻿Set-DhcpServerv4Failover -Name "dc1.kazan.wsr-srv1" -Mode LoadBalance -LoadBalancePercent 80 -MaxClientLeadTime 01:00:00 -StateSwitchInterval 00:05:00 -Force
