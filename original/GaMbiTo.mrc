ON *:START: {
  hmake NIPS 5000

  var %f = nips.db

  if ($file(%f)) { hload NIPS $qt(%f) }
}

ON *:EXIT: {
  var %f = nips.db

  if ($hget(NIPS)) && ($hget(NIPS,0).item) { hsave NIPS $qt(%f) }
}

ON *:TEXT:*:#amigos,#pensandoenvozalta,#ircops,#testing: {
  tokenize 32 $strip($1-)

  if ($1 == !ipnicks) {
    if (!$2) { msg $chan ( $+ $nick $+ ): 4ERROR 2Por favor especifique una 3IP! | return }

    var %t = $hfind(NIPS,$2,0,w)

    if (!%t) { msg $chan ( $+ $nick $+ ): 2no se encontraron resultados para4 $bold($2) | return }

    msg $chan ( $+ $nick $+ ): $iif(%t == 1,2Se encontró3 $bold(%t) 2cambios de nick:,2Hay3 $bold(%t) 2Cambios de nick) Para la IP4 $bold($2) 

    var %i = 1
    while (%i <= %t) {
      var %e = $hfind(NIPS,$2,%i,w)
      var %n = $hget(NIPS,%e)

      if (%e) && (%n) { msg $chan ( $+ $nick $+ ): 2Para la IP:4 $bold(%e) 2- $iif($numtok(%n,32) == 1,2El nick es:,2Los apodos eran:4) $bold($col_items(%n)) }

      inc %i
    }
  }

}

ON *:SNOTICE:*: {
  tokenize 32 $strip($1-)

  if (*Conectando* iswm $1-) {
    var %nick = $3
    var %ip = $remove($5,[,])

    if (%nick == $me) || (%ip == $ip) || ($iptype(%ip) !== ipv4) { return }

    var %r = $hget(NIPS,%ip)

    var %r = $addtok(%r,%nick,32)

    hadd NIPS %ip %r
  }

  if (*Cambia el nick a* iswm $1-) {
    var %old_nick = $2
    var %new_nick = $9
    var %ip = $remove($4,[,])

    if (%old_nick == $me) || (%new_nick == $me) || (%ip == $ip) || ($iptype(%ip) !== ipv4) { return }

    var %r = $hget(NIPS,%ip)

    var %r = $addtok(%r,%old_nick,32)
    var %r = $addtok(%r,%new_nick,32)

    hadd NIPS %ip %r
  }

}

alias -l bold { return $+($chr(2),$1-,$chr(2)) }
alias -l col_items {
  if (!$1) { return }

  var %1_color = 04
  var %2_color = 02

  var %t = $numtok($1-,32)
  var %i = 1

  while (%i <= %t) { 
    var %m = $gettok($1-,%i,32)

    if (%m !== $null) {
      if (!%prev) { var %tot = $addtok(%tot,$+($chr(3),%1_color,$chr(2),$chr(2),%m,$chr(3),$chr(2),$chr(2)),32) | var %prev = 1 }
      else { var %tot = $addtok(%tot,$+($chr(3),%2_color,$chr(2),$chr(2),%m,$chr(3),$chr(2),$chr(2)),32) | var %prev = 0 }
    }

    inc %i
  }

  return %tot
}