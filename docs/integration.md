---
layout: page
title: Integração
subtitle: Estratégia de integração de ativos digitais
---

Estamos vivenciando a transformação digital em diversos setores da sociedade. Na agropecuária não é diferente. Atualmente existe uma infinidade de soluções digitais disponíveis para atender aos processos de produção rural dentro e fora da porteira. Entretanto, esta "abundância" de soluções pontuais e distintas, que subsidiam apenas uma pequena parte do processo agrícola, muitas vezes levam os produtores a fazer escolhas precipitadas e a ter de lidar com a complexidade e ônus de administração de um ambiente de TI.

![Accenture: Agricultura Digital]({{ site.baseurl }}/assets/img/integration/01.png)

Assim, um grande desafio da agricultura digital é a integração de soluções pontuais em plataformas mais robustas, capazes de permitir a interoperabilidade e troca de dados entre seus diversos componentes.

No âmbito do ecossistema digital da Embrapa, esta também é uma preocupação. A forma como a Empresa está organizada induz, muitas vezes, ao desenvolvimento de soluções "soltas" e, em alguns casos, com sobreposição de funcionalidades. Por conta disso, faz-se necessário estabeler uma estratégia que vise mitigar esta fragmentação, direcionando a nossa força de trabalho em prol de um ambiente colaborativo e integrado.

Em essência, todos os ativos digitais desenvolvidos para a agropecuária são multidisciplinares. Porém, mais do que isso, muitas vezes envolvem equipes extremamente heterogênias com especialistas de diversas subáreas. Por exemplo, um dispositivo com câmera de reconhecimento de pragas por meio de visão computacional envolveria engenheiros de hardware e de software, especialista em aprendizado de máquina, biólogos, agrônomos, etc. Assim, cada solução-componente de uma plataforma maior teria uma equipe bem caracterizada, licenças de software e propriedade intelectual específica e um ciclo de vida próprio.

O desafio neste cenário, portanto, é manter o desenvolvimento de cada solução-componente compartimentalizado, de forma a não ampliar demasiadamente a complexidade na gestão do ecossistema como um todo. Neste sentido a plataforma **embrapa.io** [favorece uma arquitetura desacoplada]({{ site.baseurl }}/docs/introduction). Além disso, o [uso adequado de licenças de software]({{ site.baseurl }}/docs/licensing) também auxilia neste propósito. Em se tratando de arquitetura tecnológica, o encapsulamento de aplicações em formato de _packages_ para o uso com gerenciadores de dependência é um forte aliado. O uso do conceito de **micro-serviços** na camada de aplicações _server-side_ também favorece a quebra desta complexidade. Nas aplicações de _frontend_ o desafio é maior, uma vez que a integração de diferentes telas pode ser problemática. Para este caso, uma solução sugerida é o uso do conceito de [_micro-frontends_](https://micro-frontends.org).

Em novembro de 2016, o [_Technology Radar_ da Thoughtworks](https://www.thoughtworks.com/content/dam/thoughtworks/documents/radar/2016/11/tr_technology_radar_vol_15_pt.pdf) listou pela primeira vez o termo _micro-frontend_. Trata-se de uma técnica de desenvolvimento de _frontend_ desacoplado, onde seus pedaços podem ser desenvolvidos, testados e implementados de maneira independente, porém apresentado ao usuário como um único produto. Assim como ocorre com micro-serviços, a adoção de _micro-frontends_ [não pode ser embasada apenas em questões tecnológicas](https://www.sciencedirect.com/science/article/pii/S0950584921000549), devendo levar em conta a estruturação de times, divisões organizacionais, tomada de decisões, desenvolvimento paralelo ou com escopo estritamente delimitado, como é o caso das aplicações desenvolvidas no âmbito do ecossistema digital da Embrapa.

![Geers, M. (2020). Micro frontends in action. Manning Publications]({{ site.baseurl }}/assets/img/integration/02.png)

Apesar de suas semelhanças com a arquitetura de micro serviços (utilizada no _backend_), existem peculiaridades que são exclusivas dos _micro-frontends_. Dentre elas a mais importante refere-se à orquestração da integração das aplicações desacopladas, onde estas podem assumir um dos seguintes papéis distintos:

- **_host_:** Também chamado de _root_ ou _app shell_, é o ponto de entrada da aplicação, ou seja, o corpo principal. Aquele que o usuário acessará, que "importará" todos os _remotes_, os organizará e definirá onde e em que momento cada um será exibido ou chamado.

- **_remotes_:** São cada uma das aplicações-componentes que será integrada ao _host_ para adicionar suas funcionalidades no corpo principal da aplicação destino e se tornar, na visão do usuário, um único sistema. Os _remotes_ exportam somente o que é necessário de ser conhecido externamente.

Em termos objetivos, o uso de _micro-frontends_ está restrito, até este momento, a aplicações em JavaScript que utilizam como empacotador de código (_bundler_) o [Webpack](https://webpack.js.org), tal como aplicações desenvolvidas em [VueJS](https://vuejs.org) e [React](https://pt-br.reactjs.org). A partir de sua 5ª versão ele trás um _plugin_ denominado "**Module Federation**", que se propõe a resolver o problema do [compartilhamento de código em sistemas distribuídos](https://dev.to/marais/webpack-5-and-module-federation-4j1i).
