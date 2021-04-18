#!/bin/bash
#
# Web Server Log Tail v0.1
# by Tux {2021-04-18}
#

log='/var/logs/nginx/site.log'

tail -f $log | while read line; do

  ## Basic User Data Extraction
  uip=$(echo $line | cut -d' ' -f1) ## remote-ipaddress
  udt=$(echo $line | cut -d'[' -f2 | cut -d']' -f1) ## date/time
  usr=$(echo $line | cut -d' ' -f3) ## basic auth user (if used)
  uhd=$(echo $line | cut -d' ' -f6) ## type (GET/POST)
  upg=$(echo $line | cut -d' ' -f7) ## visited page
  ucd=$(echo $line | cut -d' ' -f9) ## http code (200|404|etc)
  urf=$(echo $line | cut -d' ' -f11) ## referral link (if exists)
  uag=$(echo $line | cut -d' ' -f12-) ## user agent (browser/os/ver)

  ## Custom Pages Monitor
  case "$upg" in
    /) txt="\e[38;5;101m@(PG) Main Page\e[0m" ;;
    /about) txt="\e[38;5;101m@(PG) About Page\e[0m" ;;
    *) txt='' ;;
  esac #pages

  ## Custom Search Monitor
  case "$upg" in
    *page?find=*) upg="\e[38;5;245m(S)> ${upg:20} \e[0m" ;;
    *) upg='' ;;
  esac #search

	## HTTP-Codes Monitor
	case "$ucd" in
		200) hcd='GOOD' ;;
		301) hcd='MOVE' ;;
		302) hcd='MOVE' ;;
		400) hcd='DENY' ;;
		401) hcd='DENY' ;;
		403) hcd='DENY' ;;
		404) hcd='NONE' ;;
		405) hcd='DENY' ;;
		444) hcd='DENY' ;;
		429) hcd='FAST' ;;
		500) hcd='IERR' ;;
		502) hcd='BERR' ;;
		504) hcd='TOUT' ;;
		*) hcd='UNKW' ;;
	esac #codes

	## Search Engines Monitor
	case "$uag" in
		*Slurp*) uag='Yahoo' ;;
		*bingbot*) uag='Bing' ;;
		*Googlebot*) uag='Google' ;;
		*YandexBot*) uag='Yandex' ;;
		*DuckDuckBot*) uag='DuckGo' ;;
		*Googlebot-Mobile*) uag='GoMobile' ;;
		*Mediapartners-Google*) uag='AdGoogle' ;;
		*Google-AdSense-Check*) uag='GoAdCheck' ;;
	esac ##engines

  ## Fixing Some Text
	urf=${urf//\"/}
	uag=${uag/;/}
	upg=${upg//\%20/ }

  ## Styling Some More Colors
	uip="\e[38;5;66m$uip\e[0m"
	hcd="\e[38;5;65m[$hcd]\e[0m"
	uag="\e[38;5;243m$uag\e[0m"

	if [ "$txt" ]; then
		echo -e " $txt \n $hcd $uip \n"
	fi #pages

	if [ "$upg" ]; then
		echo -e " $upg \n $hcd $uip \n"
	fi #search

done #while

#EOF: ~/tail.sh
