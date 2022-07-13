---
layout: page
title: Licenciamento
subtitle: Licenças de distribuição e derivação dos ativos digitais
---

*[UI]: User Interface
*[GPL]: GNU General Public License
*[BSD]: Berkeley Software Distribution
*[MIT]: Massachusetts Institute of Technology

Um dos aspectos importantes com o qual precisamos nos atentar no desenvolvimento de ativos digitais é no que tange a licença de distribuição e derivação destes softwares. Durante o ciclo de vida de um ativo, seu código-fonte sofrerá inúmeras intervenções para que sejam realizadas manutenções corretivas e evolutivas. Além disso, o código-fonte como um todo ou partes dele tendem a ser reutilizadas na criação de outros ativos digitais. Por conta disso, é essencial termos uma definição clara dos autores e titulares do ativo e das regras para distribuí-lo e derivá-lo, de forma a proteger a Embrapa e seus parceiros.

Conforme visto no [capítulo de criação de _boilerplates_]({{ site.baseurl }}/docs/boilerplate#readme), na plataforma **embrapa.io** a preocupação com o licenciamento de software dos ativos é uma constante. Por conta disso, é fortemente recomendado que _boilerplates_ sejam criadas com licenças de código-aberto "permissivas", sendo a [licença MIT](https://mit-license.org/) a mais recomendada. Licenças de código-aberto do tipo _copyleft_ tendem a ser "contaminantes", ou seja, obrigam aplicações derivadas a terem a mesma licença e se manterem, desta forma, como código-aberto. Como a Embrapa e seus parceiros desenvolvem soluções digitais com o objetivo de tranferí-las para terceiros, é fundamental que haja flexibilidade no licenciamento de modo a não interferir na definição do futuro modelo de negócios de comercialização do ativo.

Na figura abaixo pode ser observado como a [família de licenças de código-aberto do GitHub](https://articles.opexflow.com/en/programming/github-license-choos.htm) estariam agrupadas conforme a permissividade.

![Família de licenças no GitHub]({{ site.baseurl }}/assets/img/licensing/01.png)

Assim, no momento em que uma [aplicação é criada a partir de um _boilerplate_](/docs/app), a licença (arquivo `LICENSE`) na raiz do repositório derivado é alterada automaticamente para uma licença privada (_copyright_) não especificada. Cabe à equipe de desenvolvimento do ativo definir qual será a licença final da aplicação.

Vale ressaltar que, conforme vimos no [capítulo de introdução]({{ site.baseurl }}/docs/introduction#project), um projeto de ativo digital é formado por diversas aplicações desacopladas. Assim, cada uma destas aplicações terá sua própria licença de software. Por exemplo, é possível que a equipe de desenvolvimento resolva atribuir licenças privativas para um determinado pacote NPM (disponibilizado em um repositório específico) que é responsável por realizar o cálculo de simulações agropecuárias, enquanto que as aplicações JavaScript de _frontend_ e _backend_, que fazem uso deste pacote, recebam licenças de código-aberto. Desta forma, estariam protegendo o ativo principal, que contém o verdadeiro conhecimento advindo da pesquisa científica agropecuária, enquanto facilitam o reuso por outras equipes e outros softwares dos componentes de UI deste ativo.

Muitas vezes também a Embrapa, principalmente junto a seus parceiros na academia, desenvolve "pesquisas exploratórias". Este tipo de pesquisa pode resultar em ativos de valor mercadológico, mas podem ser necessários diversos trabalhos acadêmicos sequenciais para atingir este estágio. Até lá, diversos alunos, estagiários e bolsistas, além de professores e demais colaboradores, podem fazer _inputs_ intelectuais que contribuem com a tecnologia. O ônus de gestão de contratos de cooperação com estes diversos agentes, bem como o levantamento do legado histórico de peso destas contribuições podem se tornar insustentáveis. Além disso, a academia precisa demonstrar resultados práticos na forma de publicações, que podem por sua vez comprometer um registro ou patente de ativo digital.

Assim, uma forma de viabilizar projetos deste tipo é justamente mantendo suas aplicações como softwares de código-aberto até que o projeto como um todo atinja o potencial mercadológico para se buscar a transferência tecnológica junto a terceiros. Uma licença muito últi para este fim é a licença BSD (do inglês, _Berkeley Software Distribution_). Ao contrário da licença GPL, a licença BSD não requer que trabalhos derivados sejam licenciados sob a mesma licença. Requer apenas o reconhecimento dos autores e outras pequenas restrições. Como resultado os códigos BSD podem ser utilizados em projetos livres com outras licenças como Linux (GPL) ou softwares proprietários.

Por exemplo, considere a seguinte licença abaixo para um software fictício denominado "AgroApp":

```
AgroApp 1.0 - Copyright ⓒ 2022 Federal University of Mato Grosso do Sul (UFMS) and
Brazilian Agricultural Research Corporation (Embrapa) and MMHCC Tecnologia da
Informação LTDA-ME (OLIMPO). All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list
of conditions, the following disclaimer and the down lists of holders and
contributors.

2. Redistributions in binary form must reproduce the above copyright notice, this
list of conditions, the following disclaimer and the down list of holders and
contributors in the documentation and/or other materials provided with the
distribution.

3. Neither the name of the holders nor the names of its contributors may be used to
endorse or promote products derived from this software without specific prior
written permission.

4. Products derived from this software should reference it, as well the specific
version from which it derived and the down list of holders, only in the "about"
screen and documentation.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

List of Holders:

- Federal University of Mato Grosso do Sul (UFMS): https://ufms.br
- Brazilian Agricultural Research Corporation (Embrapa): https://embrapa.br
- MMHCC Tecnologia da Informação LTDA-ME (OLIMPO): https://olimpotec.com

List of Contributors:

- Jean Valjean <jean.valjean@ufms.br>
- Clarissa Dalloway <clarissa.dalloway@embrapa.br>
- Jay Gatsby <jay.gatsby@olimpotec.com>
```

As duas primeiras claúsulas (1 e 2) se referem à redistribuição do próprio software, enquanto as duas últimas (3 e 4), que são mais importantes para os nossos propósitos, se referem à criação de "produtos derivados". De todas elas, as três primeiras são originais da [licença BSD padrão](https://opensource.org/licenses/BSD-3-Clause) sem nenhuma alteração significativa. A última foi adicionada pela equipe de desenvolvimento. A intenção é simplesmente que todos os softwares derivados devem citar o software do qual foi derivado (na versão específica) e os titulares na tela de "sobre" e na documentação do software.

Neste exemplo, vamos supor que o software será derivado por uma _startup_ de alunos egressos para a criação de um novo ativo digital. O software derivado deverá, portanto, ter em sua tela de _about_ e no manual algo do tipo: "Software derivado do ativo AgroApp 1.0 desenvolvido pela Embrapa, UFMS e Olimpo". Ademais, a licença é totalmente permissiva.

Apesar de possuir uma licença de código-aberto, não é obrigatório a disponibilização do código-fonte publicamente. Portanto, após aplicá-la ao software, os interessados em obter seu código-fonte poderão fazer uma requisição via memorando a algum dos titulares utilizando a Lei de Acesso à Informação (LAI).

Como estudo de caso, considere a imagem abaixo:

![Ativo digital com múltiplas licenças de software]({{ site.baseurl }}/assets/img/licensing/02.png)

Neste exemplo temos um ativo digital com diversas aplicações desacopladas, todas elas derivadas de _boilerplates_ com licença MIT. Dentre elas, a inovação tecnológica encontra-se no componente "**Simulador**", que é um algoritmo encapsulado em um [pacote NPM](https://www.npmjs.com/). Adicionalmente, foi criado um aplicativo cliente denominado "**PWA**", implementado em [VueJS](https://vuejs.org/), para possibilitar o uso antecipado do Simulador pelo público (_early access_), de forma a servir como vitrine da tecnologia. Foram criadas também duas outras aplicações _server-side_ utilizando o _framework_ [NodeJS](https://nodejs.dev/):

- "**GraphQL API**", que implementa uma interface para o Simulador utilizando [_query language_](https://graphql.org/) e aderente ao [AgroAPI](https://www.agroapi.cnptia.embrapa.br/); e
- "**RESTful API**", que implementa uma API privada para possibilitar a persistência de dados do aplicativo cliente PWA.

O pacote NPM do simulador é então importado em todas as aplicações. Este pacote está protegido com uma licença de software privada (_copyright_). As demais aplicações são "cascas" que visam implementar camadas de interação com o Simulador e, portanto, dificilmente teriam aspectos de originalidade para caracterizar uma inovação tecnológica. Assim, é atribuído a todas elas uma licença BSD. Com isso, manutenções corretivas e evolutivas nestas aplicações de código-aberto podem ser realizadas por colaboradores, instituições e empresas parceiras sem a preocupação constante com as implicações à propriedade intelectual do ativo digital como um todo.

Repare que, com o uso combinado de licenças privadas e de código-aberto, é possível planejar melhor o ciclo de vida do ativo digital, protegendo de forma mais agressiva os componentes de inovação tecnológica e "abrindo" o restante para mitigar a complexidade na gestão da propriedade intelectual. É importante ressaltar que o tipo de licenciamento escolhido é irrelevante quanto à necessidade ou não de efetuar o registro do software junto ao [INPI](https://www.gov.br/inpi/pt-br). De forma geral, **todos os ativos digitais devem ser registrados!** Entretanto, a real necessidade deverá ser avaliada pelos comitês de propriedade intelectual da Embrapa e de seus parceiros.
