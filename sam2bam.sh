#!/bin/bash
set -euo pipefail
samtools sort -\@$(nproc) -o $1 -; samtools index -\@$(nproc) $1
#samtools view -buSh - | samtools sort - > $1; samtools index $1
