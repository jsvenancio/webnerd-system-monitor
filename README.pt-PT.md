# Webnerd System Monitor

**Uma coluna de monitorização privada para o KDE Plasma 6, pela Webnerd.pt.**

[English](README.md) · GPL-3.0-or-later · Experimental **0.3.0**

Gráficos de CPU, RAM e GPU NVIDIA, temperaturas, espaço em disco, carga do sistema e estados opcionais de serviços locais de IA.

## Estado desta versão

O widget original v0.2 foi utilizado em Nobara Linux 44 com Plasma 6.7.5. Esta versão experimental v0.3 acrescenta configuração, interface PT/EN e coletor autónomo. A Preview v0.3 já abre ao lado da v0.2; foram confirmados a página de configuração, seleção de inglês, atualização de 10 segundos e ocultação do cartão de IA. O coletor autónomo também foi iniciado e consultado com sucesso em ambiente isolado. O fluxo completo de instalação/remoção do serviço no ambiente de trabalho e outras configurações de hardware ainda não foram verificados. Outras distribuições ainda não foram verificadas.

Não exige Mission Control, Tailscale, serviços cloud ou conta externa. O coletor escuta apenas em `127.0.0.1` e não envia telemetria remota.

## Instalação

Extrai o pacote e abre o Konsole na pasta `webnerd-system-monitor`. Executa sem `sudo`.

Se já tens um coletor compatível (incluindo uma instalação existente do Webnerd AI Lab):

```bash
bash install.sh --widget-only
```

Numa instalação nova e independente:

```bash
bash install.sh --with-collector
```

O segundo modo exige `/usr/bin/python3` e `psutil` já instalados e uma porta 8765 livre. Cria um serviço systemd do utilizador, que funciona durante a sessão. Não instala dependências automaticamente. Usa os pacotes e o método de atualização suportado pela tua distribuição.

Adiciona **Webnerd System Monitor** através do modo de edição do ambiente de trabalho. Coloca à direita e ajusta a largura/altura. Existe deslocamento vertical para ecrãs mais pequenos.

## Configuração e utilização

Botão direito no widget → **Configurar → General / Geral**:

- Endereço da API: `http://127.0.0.1:8765/status` por omissão.
- Atualização: 5 a 300 segundos (15 por omissão).
- Idioma: automático, inglês ou português.
- Mostrar/ocultar GPU NVIDIA e serviços de IA.

Os gráficos guardam cinco minutos de amostras em memória; reiniciam ao carregar o widget ou mudar de API. Uma falha apresenta — e não um zero inventado. Sensores dependem do kernel/hardware; são previstos CPU AMD Tctl ou Intel Package, GPU AMD edge e NVMe Composite. A GPU NVIDIA é opcional e usa a primeira placa reportada por nvidia-smi.

O cartão das temperaturas ajusta a altura ao conteúdo. O estado local permanece independente de qualquer monitorização remota.

O coletor autónomo usa uma cache partilhada, evitando recolher novamente os sensores a cada consulta HTTP. Precisa de relógio correto; o widget rejeita amostras com mais de um minuto. A primeira consulta pode devolver 503 enquanto a cache é preparada.

Os estados de Ollama e Open WebUI são obtidos nas portas locais 11434 e 3000. Nenhuma destas aplicações é instalada por este projeto. Os endereços destes dois serviços ainda são fixos; a visibilidade é configurável. Para desativar as consultas, usa `--no-ai-checks` no coletor.

## Atualização e remoção

O instalador guarda uma cópia do widget anterior em `${XDG_STATE_HOME:-~/.local/state}/webnerd-system-monitor/backups`. Se o Plasma continuar a mostrar código antigo, guarda o trabalho, termina e inicia a sessão.

```bash
bash uninstall.sh --widget-only
# Para remover também o coletor autónomo instalado por este projeto:
bash uninstall.sh --with-collector
```

São preservados os backups, preferências Plasma e serviços externos. A instalação atual do laboratório não é alterada enquanto não executares o novo instalador.

## Documentação

O [README inglês](README.md) contém os requisitos completos, comandos do coletor e detalhes técnicos. Consulta também [privacidade](PRIVACY.md), [API](docs/API.md), [operações](docs/OPERATIONS.md) e [revisão para publicação](docs/RELEASE_REVIEW.md).

Não incluímos a captura pessoal da estação de trabalho. Uma captura anónima da versão nova poderá ser acrescentada posteriormente.

## Licença

Copyright © 2026 Webnerd.pt. GPL-3.0-or-later; texto completo em [LICENSE](LICENSE).

A página Sobre nativa inclui descrição PT/EN, copyright, autoria e função, site Webnerd.pt e contacto. O seu idioma segue o Plasma. Os links para código e problemas apontam para este repositório público; o link da autoria aponta para a Webnerd.pt.

Melhorias planeadas: [roadmap](ROADMAP.md), incluindo controlo de opacidade do fundo numa próxima sessão.
