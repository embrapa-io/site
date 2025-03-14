---
layout: page
title: Qualidade do Código
subtitle: Análise estática e detecção de problemas
---

Dentre as diversas ferramentas com as quais a plataforma **Embrapa I/O** é integrada, há uma de análise estática de código-fonte que detecta _bugs_, vulnerabilidades e problemas de qualidade, denominada [SonarQube](https://www.sonarsource.com/products/sonarqube/). Assim como as demais integrações, ela é automaticamente configurada no momento da criação de [projetos]({{ site.baseurl }}/docs/project) e [aplicações]({{ site.baseurl }}/docs/app). Está disponível para acesso em:

<div style="margin: 0 auto; text-align: center;">
    <a class="btn btn-info btn-lg" href="https://code.embrapa.io" target="_blank">code.embrapa.io</a>
</div>

Ao acessar a [_dashboard_ da plataforma](http://dashboard.embrapa.io) é mostrado para cada aplicação no _card_ do projeto, uma aba com _scores_:

![Scores do SonarQube na dashboard do Embrapa I/O]({{ site.baseurl }}/assets/img/quality/20250314092045.png)

Estes _scores_ medem (da esquerda para a direita): **manutenibilidade do código**, **confiabilidade**, **segurança**, **vulnerabilidade** e, por fim, se sua versão mais nova foi "**aprovada para entrega**". Este último _score_ (chamado pelo [SonarQube de _Quality Gate_](https://docs.sonarsource.com/sonarqube-server/latest/instance-administration/analysis-functions/quality-gates/)) é um conjunto de regras que determina se um código-fonte enviado atende a determinado padrões de qualidade, <u>podendo ser aprovado ou reprovado</u>.

![Quality Gate sendo mostrado na dashboard do Embrapa I/O]({{ site.baseurl }}/assets/img/posts/20250214144023.png)

Ao clicar sobre qualquer um dos ícones, o desenvolvedor é levado à [interface do SonarQube](https://code.embrapa.io), na qual pode autenticar utilizando a conta do [GitLab do **Embrapa I/O**](https://git.embrapa.io):

![Login no SonarQube]({{ site.baseurl }}/assets/img/posts/20250214163129.png)

Ali será possível visualizar detalhes das _issues_ e corrigí-las de forma apropriada.

![Visualização dos detalhes de uma issue no SonarQube]({{ site.baseurl }}/assets/img/posts/20250214144451.png)

Por padrão, o SonarQube está configurado para examinar todos os _commits_ apenas na _branch_ `main`, entretanto é possível estender para outras _branches_ editando o arquivo `.gitlab-ci.yml`, presente na raiz do repositório da aplicação. O monitoramento de todo ativo digital no **Embrapa I/O** é automaticamente configurado pela plataforma e não demanda nenhuma ação dos desenvolvedores.

Adicionalmente, existe um recurso visual para exibir de forma simplificada e gráfica as **linguagens de programação que predominam nas aplicações**:

![Gráfico de linguagens de programação predominantes]({{ site.baseurl }}/assets/img/posts/20250310154339.png)
