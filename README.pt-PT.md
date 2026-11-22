# Webnerd System Monitor

**Uma coluna de monitorização privada para o KDE Plasma 6, pela Webnerd.pt.**

[English](README.md) · GPL-3.0-or-later · Experimental **0.4.1**

Gráficos de CPU, RAM e GPU NVIDIA, temperaturas, espaço em disco, carga do sistema e estados opcionais de serviços locais de IA.

## Estado desta versão

A versão experimental 0.4.1 foi validada em Nobara Linux 44 com KDE Plasma 6: gráficos de rede, disposição completa sem deslocação e opacidade com pré-visualização, gravação e reposição confirmadas no computador do autor. A instalação original foi utilizada com Plasma 6.7.5. O coletor autónomo tem testes automáticos e verificação HTTP em ambiente isolado; o fluxo completo de instalação/remoção do seu serviço e outras configurações de hardware/distribuições continuam por validar.

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

Adiciona **Webnerd System Monitor** através do modo de edição do ambiente de trabalho. Coloca à direita e ajusta a largura/altura. A disposição compacta mostra todos os cartões sem deslocação e adapta-se à altura do widget. Tamanhos muito pequenos reduzem o texto; aumenta a altura/largura para melhorar a leitura.

## Configuração e utilização

Botão direito no widget → **Configurar → General / Geral**:

- Endereço da API: `http://127.0.0.1:8765/status` por omissão.
- Atualização: 5 a 300 segundos (15 por omissão).
- Idioma: automático, inglês ou português.
- Mostrar/ocultar GPU NVIDIA, rede e serviços de IA.
- Opacidade dos fundos: 20–100%, com pré-visualização durante o arrasto. Aplicar/OK guardam; descartar repõe o último valor aplicado.
- Interface de rede: vazia para a rota IPv4 predefinida ou um nome explícito.

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

A página Sobre nativa inclui autores, funções, portefólio, copyright e licença. A página Projeto reúne Blog, Repositório e Site oficial. A ajuda mantém a página de contacto atual até existir o formulário dedicado.

## Rede

Os gráficos medem tráfego da interface em kbit/s, Mbit/s ou Gbit/s, incluindo rede local. **Não são um teste de velocidade da Internet.** O coletor amostra a cada segundo; o widget apresenta a última leitura no intervalo configurado.

A seleção automática usa a rota IPv4 predefinida de menor métrica. Se não existir, escolhe a interface nas configurações. Redes apenas IPv6 e algumas VPN exigem seleção manual. Não somamos interfaces para evitar contabilizar túneis duas vezes. Aquecimento, desconexão e dados ausentes apresentam leituras indisponíveis.

Instalações do AI Lab precisam da extensão de rede no coletor existente. O instalador público não modifica esses serviços. Uma atualização apenas do widget mantém as restantes métricas, mas a rede exige uma API compatível. Para atualizar o coletor autónomo deste projeto, consulta [operações](docs/OPERATIONS.md#updating-the-bundled-collector).

## Atalho de teclado

Com apenas um widget adicionado:

```bash
python3 scripts/set-default-shortcut.py
```

Atribui Ctrl+Alt+M quando livre e preserva atalhos personalizados. Pode ser alterado/removido em Atalhos de teclado. Se o acesso automático não estiver disponível, define-o manualmente nessa página. O atalho ativa o widget; não alterna a visibilidade da coluna. A atribuição automática foi confirmada na instalação do autor; conflitos e várias instâncias continuam por validar num ambiente de trabalho real.

Consulta o [histórico de alterações](CHANGELOG.md) e o [roadmap](ROADMAP.md).
