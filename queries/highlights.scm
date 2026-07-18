;; highlights.scm — tree-sitter highlight query for the cisco_ios_jinja2 grammar.
;;
;; Capture index:
;;   @keyword            — IOS command keywords (anonymous prec-2 literals matched
;;                         inside their parent `*_statement` node; see grammar.js
;;                         `token(prec(2, "..."))`). List is representative — every
;;                         rich `*_statement` follows the same `(node "kw" @keyword)`
;;                         pattern, so adding more is a one-line change.
;;   @keyword.control    — Jinja2 control words (for/endfor/if/elif/else/endif/
;;                         set/block/endblock/macro/endmacro/with/endwith/include/
;;                         extends/import/call/endcall/filter/endfilter/raw/endraw).
;;                         These are aliased to the anonymous `_keyword` token via
;;                         the grammar's `keyword()` helper; one rule catches them all.
;;   @type               — section header keywords (interface/router) and the
;;                         routing-protocol token (bgp/ospf).
;;   @string             — quoted Jinja strings (`"..."` / `'...'`).
;;   @comment            — IOS `! comment` and Jinja `{# comment #}`.
;;   @punctuation.special  — Jinja statement delimiters `{%`/`%}` (aliased to the
;;                         anonymous `statement_start`/`statement_end` tokens).
;;   @punctuation.bracket  — Jinja output delimiters `{{`/`}}`.
;;   @constant.builtin   — the `!` section terminator (`eos`).
;;
;; NOTE: anonymous prec-2 keyword tokens (e.g. `permit`, `hostname`) are NOT named
;; nodes — they must be matched by literal string inside their parent statement
;; node, e.g. `(permit_statement "permit" @keyword)`. Anonymous aliases such as
;; `statement_start`/`statement_end` are matched as quoted strings in the query
;; (`"statement_start"`), not as `(statement_start)` — that form is rejected by
;; the query compiler because the alias is to a string, not a named symbol.

; ---------------------------------------------------------------------------
; @keyword — IOS command keywords (matched by literal inside parent statement)
; ---------------------------------------------------------------------------
(permit_statement     "permit"              @keyword)
(deny_statement       "deny"                @keyword)
(hostname_statement   "hostname"            @keyword)
(version_statement    "version"             @keyword)
(service_statement    "service"             @keyword)
(description_statement "description"        @keyword)
(shutdown_statement   "shutdown"            @keyword)
(speed_statement      "speed"               @keyword)
(duplex_statement     "duplex"              @keyword)
(mtu_statement        "mtu"                 @keyword)
(address_family_statement   "address-family"      @keyword)
(neighbor_statement         "neighbor"            @keyword)
(network_statement          "network"             @keyword)
(redistribute_statement     "redistribute"        @keyword)
(passive_interface_statement "passive-interface"  @keyword)
(router_id_statement        "router-id"           @keyword)
(login_statement            "login"               @keyword)
(password_statement         "password"            @keyword)
(transport_statement        "transport"           @keyword)
(exec_timeout_statement     "exec-timeout"        @keyword)
(access_class_statement     "access-class"        @keyword)
(match_statement       "match"               @keyword)
(set_statement         "set"                 @keyword)
(class_statement       "class"               @keyword)
(snmp_server_statement "snmp-server"         @keyword)
(scheduler_statement   "scheduler"           @keyword)
(hw_module_statement   "hw-module"           @keyword)
(tacacs_server_statement "tacacs-server"     @keyword)
(negation_keyword) @keyword

; The list above is representative (~25 highest-frequency keywords). Every other
; rich `*_statement` in the grammar follows the identical pattern
; `(rule_name "kw-literal" @keyword)` — extend as desired. See src/node-types.json
; for the full anonymous-keyword inventory.

; ---------------------------------------------------------------------------
; @keyword.control — Jinja2 control words (alias "_keyword", anonymous)
; ---------------------------------------------------------------------------
; One rule catches for/endfor/if/elif/else/endif/set/block/macro/with/include/
; extends/import/call/filter/raw and their `end*` partners, since the grammar's
; `keyword()` helper aliases them all to the anonymous `_keyword` token.
"_keyword" @keyword.control

; ---------------------------------------------------------------------------
; @type — section headers + routing protocol
; ---------------------------------------------------------------------------
(interface_header "interface" @type)
(router_header    "router"     @type)
(routing_protocol) @type

; ---------------------------------------------------------------------------
; @string — quoted Jinja strings (used in include/import)
; ---------------------------------------------------------------------------
(string) @string

; ---------------------------------------------------------------------------
; @comment — IOS `!`-comment + Jinja `{# #}` comment
; ---------------------------------------------------------------------------
(ios_comment) @comment
(j2_comment)  @comment

; ---------------------------------------------------------------------------
; @punctuation.special — Jinja statement delimiters `{%` / `%}` (anonymous aliases)
; ---------------------------------------------------------------------------
"statement_start" @punctuation.special
"statement_end"   @punctuation.special

; ---------------------------------------------------------------------------
; @punctuation.bracket — Jinja output delimiters `{{` / `}}`
; ---------------------------------------------------------------------------
(output "{{" @punctuation.bracket
        "}}" @punctuation.bracket)

; ---------------------------------------------------------------------------
; @constant.builtin — `!` section terminator (named `eos` node)
; ---------------------------------------------------------------------------
(eos) @constant.builtin
