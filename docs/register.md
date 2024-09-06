---
layout: page
title: Registro
subtitle: Registro de software junto ao INPI
---

Todo ativo digital da Embrapa a ser disponibilizado para o público final deverá tramitar pelo Comitê Local de Propriedade Intelectual (CLPI) da Unidade Descentralizada e pela Supervisão de Propriedade Intelectual (SIN/GAT/PRIN) que, eventualmente, demandarão seu registro (ou depósito) junto ao [Instituto Nacional da Propriedade Industrial (INPI)](https://www.gov.br/inpi/).

No INPI o registro deverá ser realizado na modalidade "**Programa de Computador**". Atualmente o INPI não resguarda mais o código-fonte em si do ativo digital, mas sim apenas o "resumo digital _hash_" deste código-fonte. Assim, durante o processo interno de registro do ativo digital, será demandada à equipe de desenvolvimento a geração desta _hash_.

Para fazer isso no **Embrapa I/O**, recomendamos considerar a **macro-versão do ativo** (veja sobre os conceitos de [rodadas evolutivas]({{ site.baseurl }}/docs/introduction#round) e [versões]({{ site.baseurl }}/docs/introduction#version) utilizados pela Plataforma). Assim, poderá ser realizado o depósito/registro da versão 1.0, depois de uma versão 2.0 e assim sucessivamente.

Para cada registro de uma macro-versão, deverão ser agrupados os códigos-fonte de todas as aplicações desenvolvidas no projeto que compõem o ativo digital. É importante que **todos os ajustes essenciais nas aplicações sejam realizados antes de executar o procedimento de geração da _hash_**, pois esta funciona como uma "foto" daquele estado exato do código-fonte e qualquer alteração posterior gera uma _hash_ completamente diferente.

Para início do procedimento, deverá ser tagueado o _commit_ no repositório GIT que será alvo do registro. Por exemplo, vamos supor que estamos fazendo o registro da 4ª macro-versão do aplicativo [Pasto Certo](https://www.infoteca.cnptia.embrapa.br/handle/doc/1166788) e que este aplicativo é formado por 3 aplicações desacopladas:

- `pwa`: aplicação de _frontend_ que implementa a interface para os usuários (público final) em formato [_Progressive Web Application_](https://web.dev/learn/pwa/progressive-web-apps);
- `manager`: aplicação de _frontend_ que implementa a interface para os gestores da ferramenta em formato [_Single-Page Application_](https://www.iugu.com/blog/single-page-applications); e
- `api`: aplicação de _backend_ (_server side_) que implementa uma API RESTful e persiste os dados da solução como um todo em nuvem.

Assim, para definir no repositório da aplicação `pwa` do Pasto Certo o _commit_ exato que será depositado no INPI, é criada uma _tag_ com prefixo `INPI-` seguido do número da macro-versão. No exemplo ficaria portanto "`INPI-4.0`", conforme pode ser visto abaixo:

![Criando a tag para registro no INPI.]({{ site.baseurl }}/assets/img/register/tag.png)

É esperado que esta _tag_ seja criada no mesmo _commit_ de outra, que já tenha sido validada em ambiente de homologação ou mesmo já esteja em produção, caracterizando uma versão "finalizada" da aplicação. No exemplo acima, o registro está sendo feito para a versão `4.23.6-6` de produção (_branch_ `release`).

O mesmo deverá ser feito, seguindo o exemplo, nos repositórios das aplicações `manager` e `api`.

> **Atenção!** Caso esteja utilizando um cliente GIT local, não se esqueça de fazer o _push_ da _tag_ para a `origin`.

Uma vez que os repositórios estejam devidamente tagueados, pode-se iniciar o processo de exportação do código e geração do "resumo digital _hash_". Para isso, primeiro crie um novo diretório onde achar mais conveniente:

```
mkdir inpi
cd inpi
```

Em seguida, faça o clone dos repositórios de código-fonte (a partir da _tag_ criada) de todas as aplicações que compõem o ativo digital:

```
git clone --depth 1 --branch INPI-4.0 git@git.embrapa.io:pasto-certo/api.git
git clone --depth 1 --branch INPI-4.0 git@git.embrapa.io:pasto-certo/pwa.git
git clone --depth 1 --branch INPI-4.0 git@git.embrapa.io:pasto-certo/manager.git
```

Agora, apague os diretórios `.git` de forma a remover a relação com o repositório GIT. Com isso restará puramente o código-fonte a ser registrado:

```
rm -rf api/.git
rm -rf pwa/.git
rm -rf manager/.git
```

Em seguida, compacte todo o diretório `inpi`, inicialmente criado, utilizando, p.e., o ZIP:

```
cd ..
zip -vr pasto-certo_v4_inpi_20240905.zip inpi -x "*.DS_Store"
```

No comando acima foi utilizado o utilitário de linha de comando `zip` do MacOS. Reparem que são excluídos arquivos denominados `.DS_Store`, que são criados automaticamente por este sistema operacional e não fazem parte do código-fonte.

Por fim, gere a _hash_ `SHA-512`:

```
shasum -a 512 pasto-certo_v4_inpi_20240905.zip
```

É recomendado que o arquivo compactado e a _hash_ sejam armazenadas de forma permanente no repositório `io-doc` do GIT do projeto.

> **Atenção!** Conforme a norma atual, a Unidade Descentralizada deverá resguardar o código-fonte a ser depositado no INPI. Portanto, o NTI da Unidade também deve manter uma cópia permanente, em ambiente local, do arquivo compactado gerado acima.
