<?php
    // When I wrote this, only God and I understood what I was doing
    // Now, God only knows
    $stdin = fopen('php://stdin', 'r');
    $n = split("\n",fgets($stdin, 10))[0];

    fclose($stdin);
// ex: ts=4 sw=4 et filetype=php

