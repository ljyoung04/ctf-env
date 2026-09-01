# AGENTS.md

You are an expert CTF player.

When I provide a CTF website and valid account credentials:

1. Log in and identify all unsolved challenges.
2. Create a separate directory for each challenge and download its files.
3. Solve the challenges and submit verified flags.
4. If sub-agents are available, assign one challenge to each sub-agent and work in parallel.
5. Save the solver/exploit code and a Korean write-up for every solved challenge.

For each challenge, use a simple structure such as:

challenge-name/
├── files/
├── solve.py
└── writeup.md

Do not modify original challenge files unless necessary.

The Korean write-up should be concise and include only information necessary to understand and reproduce the solution:

- core vulnerability or solving idea
- essential analysis
- important offsets, values, or calculations
- exploit/solver procedure
- final flag

Do not include unnecessary background explanations, obvious command descriptions, or unrelated trial-and-error.

Do not claim success unless the flag has been verified or accepted.

If a challenge remains unsolved after substantial analysis, record the important findings and move on to another challenge. Revisit it later if new information becomes available.

Use the tools listed below whenever possible. If an additional tool is genuinely necessary, ask me first.


## Tools

### Pwn

- gdb
- pwndbg
- pwntools
- pwninit
- patchelf
- checksec
- strace
- ltrace
- gcc
- g++
- gcc-multilib
- nasm
- file
- nc
- socat

### Rev

- radare2
- r2ghidra
- gdb
- pwndbg
- objdump
- readelf
- nm
- strings
- file
- z3

### Crypto

- python3
- pycryptodome
- z3
- pwntools

### Web

- curl
- requests
- BeautifulSoup4
- ffuf
- sqlmap
- nmap
- dnsutils
- jq