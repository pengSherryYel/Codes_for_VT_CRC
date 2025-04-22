less ../data/vt_bp.datapath |xargs -i echo -e '#!/usr/bin/bash\nsh ../src/wf_qc_ass_ckv_mmseqs_replidec_bt.sh {}' |split -l 2 - vt.split.sbatch.sh
less ../data/virome.datapath |xargs -i echo -e '#!/usr/bin/bash\nsh ../src/wf_removePhiX_human_qc_ass_ckv_mmseqs_replidec_bt.sh {}'|split -l 2 - virome.split.sbatch.sh
