# tree-sitter-cisco-ios-jinja2

A [tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar for Cisco IOS configuration files **with Jinja2 templating** support — parse real `running-config` files or Jinja2-templated ones (for `ciscoconfparse`, `nornir`, `Ansible`, …) into a structured AST.

## Installation

### Node / npm

```bash
npm install tree-sitter-cisco-ios-jinja2
```

### Python

```bash
pip install tree-sitter-cisco-ios-jinja2
```

### Go

```bash
go get github.com/dgethings/tree-sitter-cisco-ios-jinja2
```

### C (build from source)

```bash
make && make install    # installs libtree-sitter-cisco-ios-jinja2.{a,so} + headers + .pc
```

## Usage

### Node

```js
import Parser from "tree-sitter";
import CiscoIosJinja2 from "tree-sitter-cisco-ios-jinja2";

const parser = new Parser();
parser.setLanguage(CiscoIosJinja2);

const tree = parser.parse(
  "interface GigabitEthernet0/0\n description uplink\n speed 1000\n!\n",
);
console.log(tree.rootNode.toString());
```

```text
(config
  (interface_section
    (interface_header
      name: (interface_name))
    (description_statement
      text: (value))
    (speed_statement
      value: (value))
    (eos)))
```

### Python

```python
from tree_sitter import Language, Parser
import tree_sitter_cisco_ios_jinja2

parser = Parser(Language(tree_sitter_cisco_ios_jinja2.language()))

tree = parser.parse(
    b"interface GigabitEthernet0/0\n"
    b" description uplink\n"
    b" speed 1000\n"
    b"!\n"
)
print(tree.root_node.sexp())
```

## Supported syntax

- **IOS sections** (bodies terminated by `!`):
  - `interface <name>` … `!` → `interface_section`
  - `router <ospf|bgp> <id>` … `!` → `router_section`
- **Generic command lines** — every word-leading line parses to a `command_line` node (`identifier` + `repeat(arg)`); multi-word command identity (e.g. `ip address`) is resolved downstream by the LSP against `data/commands.json`, not by the AST.
- **Rich families** (override the generic backbone where fields matter):
  - **interface** — `description`, `shutdown`, `speed`, `duplex`, `mtu`
  - **router / address-family** — `address-family`, `neighbor`, `network`, `redistribute`, `passive-interface`, `router-id`, `exit-address-family`, `metric-style`, `graceful-restart`, `queue-depth`, `compatible`, `auto-cost`, `aggregate-address`, `af-interface`, `autonomous-system`, `maximum-prefix`, `summary-prefix`, `default-information`, `distribute-list`
  - **global** — `snmp-server`, `scheduler`, `hw-module`, `memory`, `rtr`, `exception`, `subscriber`, `mac-address-table`, `kerberos`, `boot`, `tacacs-server`, `parser`
  - **line** — `login`, `password`, `transport`, `exec-timeout`, `access-class`, `terminal-type`, `length`, `width`, `editing`, `motd-banner`, `escape-character`, `activation-character`, `databits`, `parity`, `padding`, `stopbits`
  - **access-list (ACE)** — `permit`, `deny` (generic across the five ACL/mACL sub-modes)
  - **misc** — `match`, `set`, `class` (multi-mode generics), `remote-span`, `private-vlan` (vlan), `police`, `priority`, `drop`, `random-detect` (policy-map-class), `auto-sync` (redundancy), `continue` (route-map)
  - **service / timestamps / hostname / version** — the earliest rich rules; see [`test/corpus/service.txt`](test/corpus/service.txt)
- **Generic `no` negation** — `no <command>` wraps any line or section header as a `negated_statement`.
- **Jinja2 templating**:
  - Control: `{% for %}` / `{% endfor %}` (with optional `{% else %}`), `{% if %}` / `{% elif %}` / `{% else %}` / `{% endif %}`, `{% set %}` / `{% endset %}`, `{% block %}` / `{% endblock %}`, `{% macro %}` / `{% endmacro %}`, `{% call %}`, `{% filter %}`, `{% with %}` / `{% endwith %}`, `{% extends %}`, `{% include %}`, `{% import %}`, `{% raw %}`
  - Output: `{{ expr }}`
  - Comments: `{# ... #}`

## Development

### Prerequisites

- Node.js + a C compiler (for `node-gyp` building `src/parser.c`)
- `tree-sitter-cli` — provided as an npm devDependency (`npm install` brings it)
- Go ≥ 1.23
- Python ≥ 3.10 + [`uv`](https://docs.astral.sh/uv/)

### Running tests

```bash
make test                                                         # runs tests in tests/corpus
npm install && npm test                                           # node binding
go test ./bindings/go                                             # go binding
```

### Development loop

Add test(s) to [test/corpus](./test/corpus/), either by adding to an existing file or by creating a new file.
Run the tests using `make test`. Only your added test should fail.
Update [grammer.js](./grammar.js) to implement the parser and generate the AST.
Rerun the test using `make test`. All tests should pass.
