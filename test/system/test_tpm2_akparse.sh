#!/bin/bash
#;**********************************************************************;
#
# Copyright (c) 2016, Intel Corporation
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of Intel Corporation nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.
#;**********************************************************************;

onerror() {
    echo "$BASH_COMMAND on line ${BASH_LINENO[0]} failed: $?"
    exit 1
}
trap onerror ERR

cleanup() {
    rm -f ak.out akparse.out ek.pub ak.pub ak.name &>/dev/null

    # Evict persistent handles, we want them to always succeed and never trip
    # the onerror trap.
	tpm2_evictcontrol -Q -A o -H 0x8101000b 2>/dev/null || true
	tpm2_evictcontrol -Q -A o -H 0x8101000c 2>/dev/null || true
}
trap cleanup EXIT

cleanup

tpm2_getpubek -Q -H 0x8101000b -g rsa -f ek.pub

tpm2_getpubak -Q -E 0x8101000b -k 0x8101000c -g rsa -D sha256 -s rsassa -f ak.pub -n ak.name

tpm2_akparse -Q -f ak.pub -k akparse.out

exit 0
