# Protheus Docker — Coolify

Ambiente **Protheus 12.1.2510** de desenvolvimento e teste, como **Docker
Compose** no Coolify.

> **As imagens são para uso estritamente de desenvolvimento e não são
> homologadas para ambientes de produção.** — documentação TOTVS

---

## Como este branch difere do `main`

O `main` constrói imagens e tenta carregar os artefatos licenciados **dentro do
repositório**, via Git LFS. Este branch mantém a construção das imagens — pela
mesma razão que ela existe — mas tira os artefatos do Git.

| | `main` | este branch |
|---|---|---|
| Imagens | derivadas por `Dockerfile` | derivadas por `Dockerfile` |
| `dmidecode` falso (licença) | sim | **sim, mantido** |
| Artefatos licenciados | no Git, via LFS | **fora do Git**, no host |
| RPO / dicionário | ponteiros LFS | arquivos reais, baixados do Drive |
| Download dos artefatos | manual | **automático no boot**, idempotente |
| `appserver.ini` | copiado para a imagem | gerado em runtime |
| `specialkey` | `exemplo`, versionado | variável do Coolify |
| Criação de banco | implícita (`POSTGRES_DB`, inerte) | conferida no start |
| Tags das imagens | `latest` + `12.1.2210_bra` | **fixadas**, `12.1.2510_bra` |

**Por que os artefatos saíram do Git.** No `main`, `resources/TTTM120.RPO`,
`resources/sxsbra.txt` e `resources/hlp*.txt` estão versionados como ponteiros
LFS de **134 bytes** — um RPO de verdade tem 606 MB. O build consome um arquivo
vazio. E não há saída dentro do Git: ele recusa arquivos acima de 100 MB, e o LFS
gratuito dá 1 GB de armazenamento contra os ~1,2 GB do conjunto.

**Por que as imagens continuam sendo construídas.** Por causa do
`resources/dmidecode`. A licença do Protheus se vincula a identificadores de
hardware (UUID e serial do sistema), que num container vêm do host e variam de
máquina para máquina. O mock devolve valores fixos. Essa solução já estava
validada aqui e é a peça que faz a licença funcionar.

---

## O que vem de onde

Tudo o que o Drive tem, o Drive fornece — e **automaticamente**: o serviço
`fetch-artifacts` baixa e renomeia no primeiro boot. Nada é copiado à mão.

| Arquivo | Origem | Vai para |
|---|---|---|
| `tttm120.rpo` (606 MB) | Drive | `/srv/protheus/apo/` |
| `sxsbra.txt` (592 MB) | Drive | `/srv/protheus/systemload/` |
| `sx2.unq` (80 KB) | dentro de `DICIONARIOS_DIF.zip` | `/srv/protheus/systemload/` |
| 69 × `.xnu` | dentro de `MENUS.zip` | `/srv/protheus/system/` |
| `hlp{por,eng,spa}.txt` | dentro de `HELPS_COMPL.zip` | `/srv/protheus/systemload/` |

O `sdfbra.txt` (287 MB, dentro do mesmo zip do `sx2.unq`) **não é baixado**: é
dicionário **diferencial**, para atualizar dicionário existente, não para montar
ambiente novo.

No container: `sourcepath` → `/opt/totvs/protheus/apo`, e `startpath=/system` é
**relativo** a `rootpath`, por isso os menus vão em `protheus_data/system`.

---

## Pré-requisitos

- Host do Coolify em **x86-64** (as quatro imagens são `linux/amd64`, e só).
- **~1,5 GB livres** para os artefatos.
- `curl` e (`unzip` ou `python3`) no host.
- Ajuste de kernel no host — **nenhum compose aplica isto:**

  ```bash
  echo 32767 > /proc/sys/fs/file-max                                              # até o próximo boot
  echo 'fs.file-max = 32767' > /etc/sysctl.d/99-protheus.conf && sysctl --system  # permanente
  ```

---

## Deploy

### 1. O download dos artefatos é automático

Não há passo manual. O serviço `fetch-artifacts` baixa os ~1,2 GB do Drive no
primeiro boot e grava já com os nomes que o Protheus espera — o Drive entrega
nomes longos em maiúsculas, o container quer caminhos fixos.

É **idempotente**: cada arquivo é conferido por tamanho antes de baixar. O
download acontece uma vez; os boots seguintes levam décimos de segundo.

Testado de verdade: a primeira execução baixou os cinco conjuntos e conferiu
todos; a segunda levou **0,108 s** sem baixar nada.

Para rodar à mão (Drive fora do ar, ou antes do deploy):

```bash
DATA_DIR=/srv/protheus bash resources/fetch-artifacts.sh
```

### 2. Criar o recurso no Coolify

1. **New Resource → Application → Docker Compose** (build pack **Docker Compose**,
   escolhido na criação — não há troca depois).
2. Aponte para este repositório e para o branch.
3. **Environment Variables:**

   | Variável | Valor |
   |---|---|
   | `PROTHEUS_SPECIALKEY` | `openssl rand -hex 16` |
   | `TZ` | `America/Sao_Paulo` (opcional) |
   | `FETCH_ARTIFACTS` | `1` (padrão) — `0` desliga o download |

4. **Domains for `appserver`** — uma linha só:

   ```
   https://protheus.stellvick.fun:8080
   ```

   O número é a porta **dentro do container**. O domínio serve o **WebApp**.

   O **REST não fica no domínio**: fica na porta 8081 publicada no host, em
   HTTP puro (ver "Acesso externo" abaixo). Se preferir o REST com TLS, troque
   esta linha por duas e use dois nomes — o Coolify não distingue duas portas
   diferentes no mesmo hostname:
   ```
   https://protheus.stellvick.fun:8080
   https://protheus-api.stellvick.fun:8081
   ```
5. **Deploy.**

A ordem de subida é resolvida pelo compose:

```
license + postgres-iniciado
    →  fetch-artifacts (baixa os artefatos do Drive, ~1,2 GB, uma vez)
    →  initdb (confere o banco WIN1252)
    →  seed-config (escreve appserver.ini, language.ini e dbaccess.ini)
    →  dbaccess-postgres + appserver
```

`fetch-artifacts`, `initdb` e `seed-config` saem com código 0 e ficam parados — é o esperado. Por
isso carregam `exclude_from_hc: true`: sem isso o Coolify poderia marcar o
recurso inteiro como doente por causa de dois containers que terminaram bem.

### 3. Verificar

```bash
bash host/99-verify.sh https://protheus.stellvick.fun https://protheus-api.stellvick.fun
```

Testa contra os containers reais: estados, banco, `isql` pelo alias `protheus`,
porta 1234, WebApp e `/rest`. Esperado no REST: **401 ou 403**, não 200 —
`[HTTPREST] SECURITY=1` faz o endpoint vivo recusar quem chega sem credencial.

### 4. Apontar o TDS

No assistente *Add Server* do `TOTVS.tds-vscode`: **address** = IP/host do
servidor, **port** = `1234`.

---

## Serviços

| Serviço | Imagem | Porta |
|---|---|---|
| `license` | `totvsengpro/license-dev:3.7.0` | interna, 5555 |
| `postgres-iniciado` | `totvsengpro/postgres-dev:12.1.2510_bra` | interna, 5432 |
| `fetch-artifacts` | one-shot (`alpine` + curl) | — |
| `initdb` | one-shot | — |
| `seed-config` | one-shot | — |
| `dbaccess-postgres` | `totvsengpro/dbaccess-postgres-dev:24.1.1.0` | interna, 7890 |
| `appserver` | `totvsengpro/appserver-dev:24.3.1.1` | **1234, 8080 e 8081 publicadas** + domínio |

---

## Acesso externo

| Endereço | Serve | TLS |
|---|---|---|
| `https://protheus.stellvick.fun` | WebApp (container 8080) | **sim**, Let's Encrypt |
| `<host>:8080` | WebApp (container 8080) | não |
| `<host>:8081` | REST (`/REST`, container 8081) | não |
| `<host>:1234` | TDS / SmartClient (protocolo binário) | não |

Sondagem do host em 2026-10-20: **8080 e 8081 livres**; **8000 ocupada** pelo
painel do Coolify (não usar); 80 e 443 com o proxy; 1234 abre quando o AppServer
subir. Trocar os números das portas do host é uma linha no compose — a da
esquerda, antes dos dois-pontos.

**Aviso honesto:** as portas 8080 e 8081 são HTTP **puro**, sem TLS. O REST sobe
com `[HTTPREST] SECURITY=1`, isto é, autenticação Basic — e Basic sobre HTTP
viaja em claro, com a senha legível por qualquer um no caminho. O WebApp tem o
mesmo problema no login. Se o acesso for sair da sua rede, use o domínio com
certificado ou restrinja as portas por firewall ao seu IP.

---

## Fatos verificados (não supostos)

Todos lidos **de dentro das imagens**, não da documentação:

- **O banco `protheus` já existe, em WIN1252.** Li o catálogo `pg_database`
  (`global/1262`) da imagem: `datdba=10`, `encoding=24` (WIN1252), `connlimit=-1`.
  É por isso que `initdb` confere em vez de criar — e por isso as variáveis
  `POSTGRES_PASSWORD`/`POSTGRES_DB` do `main` são inertes: o cluster vem
  pré-inicializado e o `docker-entrypoint` pula o `initdb`.
- **A senha do superusuário é `postgres`**, provada comparando o verificador
  SCRAM-SHA-256 de `global/1260` (`pg_authid`) com a chave derivada do candidato.
  Bate byte a byte.
- **A imagem do AppServer já traz o `webapp.so`** e as pastas `apo/`,
  `systemload/` e `system/` **vazias** — exatamente os três pontos que o bind
  mount do host preenche.
- **As quatro imagens são `linux/amd64`**, e só.
- **`dbaccess-postgres-dev` traz `/usr/lib64/libodbc.so` e `/usr/bin/isql`** —
  o caminho que o `dbaccesscfg` recebe em `-c` existe mesmo.

---

## Conformidade com a release 12.1.2510

A release note oficial **DFRM1-37254** (TDN, *Obrigatoriedade da Porta
Multiprotocolo*) torna duas chaves **obrigatórias** a partir da 12.1.2510:

```
Seção [DRIVERS]   MultiProtocolPort=1
Seção [GENERAL]   app_environment=<nome do ambiente a ser habilitado no REST>
```

Sem elas o serviço pode recusar acesso com a mensagem *"Porta Multiprotocolo -
Não foi possível identificar a configuração do ambiente"*.

O `resources/seed-config.sh` gera as duas. **Atenção à seção:** a nota exige
`app_environment` em `[GENERAL]`. A configuração herdada do `main` trazia a
chave em `[environment]` — que é outra seção, e não atende o requisito.

Verificado por execução real do script, com um verificador que percorre o INI e
confere em que seção cada chave caiu — não por leitura.

---

## Segredos

- `PROTHEUS_SPECIALKEY` — variável do Coolify, única credencial configurável.
- **Não há senha de banco configurável**, e é deliberado: o cluster já vem
  pronto, com o par `postgres`/`postgres` documentado pelo fabricante e
  verificado acima. A porta 5432 é interna ao recurso.
- `dbaccess.ini` é **gerado** pelo `dbaccesscfg` que vive na própria imagem, com
  a senha criptografada como o fabricante especifica. Um arquivo escrito à mão
  pode funcionar — o `main` usa um —, mas gerar é o caminho garantido.

---

## Operação

**Trocar o RPO:**

```bash
cp /caminho/novo/TTTM120.RPO /srv/protheus/apo/tttm120.rpo
docker restart $(docker ps -q --filter label=com.docker.compose.service=appserver)
```

Nada é reconstruído: `apo/` é bind mount.

**Configuração:** `appserver.ini`, `language.ini` e `dbaccess.ini` são
**regerados a cada deploy**. Edição manual nesses arquivos se perde — de
propósito: o repositório é a fonte da verdade. Para mudar configuração, altere
`resources/seed-config.sh` e faça push.

**Logs:** `docker exec <id> tail -f /opt/totvs/appserver/console.log`, ou o log de
deploy do Coolify, onde aparecem as saídas de `initdb` e `seed-config`.

---

## Limites conhecidos

1. **Substituição de variáveis em duas camadas — resolvido na prática.** O
   Coolify substitui antes do `docker compose`, que substitui de novo. Num script
   *inline* isso obrigava a dobrar cada cifrão (`$${VAR}`), e uma dobra esquecida
   gravaria o `specialkey` **vazio**, em silêncio. Os scripts agora vivem em
   `resources/*.sh`, versionados: o Compose não os interpreta, o bash sim.
   Ainda vale conferir depois do deploy: `grep specialkey /srv/protheus/appserver.ini`.
2. **Google Drive no caminho de boot.** O `fetch-artifacts` depende de um link
   público do Drive no primeiro boot. Depois de baixado, os arquivos ficam na
   pasta do host e sobrevivem a tudo — mas se o Drive estiver indisponível antes
   disso, o recurso não sobe. `FETCH_ARTIFACTS=0` desliga o download e usa só o
   que estiver em disco. Links públicos sofrem limitação de banda do Google, e é
   exatamente por isso que a conferência por tamanho existe: baixar 1,2 GB a cada
   boot seria pedir para ser bloqueado.
3. **Licença.** O `license-dev` tráz um MAC fixo (`00:50:56:AC:C8:2B`) no
   `licenseserver.ini`. O `dmidecode` falso cobre UUID e serial; se a licença
   ainda recusar, o MAC é o próximo lugar a olhar.
4. **Versões.** AppServer `24.3.1.1` com License `3.7.0` é o par que a TOTVS
   publica junto, de outubro/2025. Não usamos os tarballs licenciados do Drive
   (`appserver 24.3.1.5`, `license 3.7.1`) porque o `TOTVSLICENSE` é um
   **instalador Java** para `/totvs/totvslicensevirtual`: exigiria JDK no build e
   um layout impossível de verificar sem executá-lo.
5. **Porta 1234 exposta.** O AppServer exige autenticação própria, mas a porta
   exposta é a porta exposta. Restrinja por firewall se puder.
6. **Não homologado para produção.**

---

## Arquivos

```
docker-compose.yml          recursos, ordem de subida, domínios
fetcher.Dockerfile          imagem mínima (alpine + curl + unzip) do download
appserver.Dockerfile        ┐
dbaccess.Dockerfile         │ derivadas das oficiais, para o dmidecode falso
license.Dockerfile         │
postgres.Dockerfile         ┘
resources/dmidecode         mock que estabiliza a identidade de hardware
resources/fetch-artifacts.sh  baixa e renomeia os artefatos do Drive
resources/seed-config.sh    gera appserver.ini, language.ini e dbaccess.ini
.env.example               as três variáveis
host/99-verify.sh          verificação pós-deploy (roda no host, inspeciona containers)
```

Nenhum artefato licenciado é versionado. `resources/` contém apenas texto.
