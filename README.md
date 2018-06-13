# Godot-Engine-3.0-Behavior-Nodes
The link between Godot and no-coding tools for video games creation

(in english the second half)

Come dice brevemente il titolo, questo progetto ha l'ambizione di voler diventare l'anello di congiunzione tra Godot e gli strumenti per lo sviluppo di videogiochi no-coding (ad esempio Construct 2/3, ClickTeam Fusion 2.5, etc.)

Poter entrare nel merito del codice di quello che si sta realizzando consente una potenza altrimenti irraggiungibile (ovviamente, non sto dicendo nulla di nuovo), tuttavia poter creare un prototipo funzionante dell'idea che abbiamo in mente in pochi passaggi è qualcosa che alza la motivazione e la produttività a livelli mai visti (è qui che si collocano gli strumenti precedentemente citati).

A titolo di esempio, da qui in avanti, prenderò a riferimento solo Construct 2 e ClickTeam Fusion 2.5.

Entrambi questi prodotti hanno - come è giusto che sia - un ambiente di sviluppo pesantemente incentrato sulle proprie caratteristiche (ad esempio entrambi hanno uno strumento, più o meno valido, per l'editing delle immagini che costitutiscono gli sprite, che consente di creare prototipi molto rapidamente).
Entrambi hanno un approccio di tipo drag & drop, sia per quanto riguarda il posizionamento degli oggetti nell'area di lavoro, sia per quanto concerne la scrittura del "codice".

Mentre ClickTeamFusion 2.5 ha una serie di esportatori (acquistabili separatamente) per poter pubblicare la propria opera su varie piattaforme in codice nativo, Construct 2 produce solo giochi HTML5 (per cui per poterlo portare sulle varie piattaforme occorrono poi appositi wrapper, come nwjs per desktop o cordova per mobile.

La forza di questi strumenti sta *non solo* nel fornire, di base, un gran bel set di strumenti pronti all'uso, da poter aggiungere alla scena, che si incastrano tra loro per produrre, rapidamente, qualcosa di funzionante, ma soprattutto nella possibilità di crearne ed aggiungerne di nuovi (entrambi hanno alle spalle delle comunità molto vive che hanno prodotto veramente tanti componenti aggiuntivi).

Inoltre Construct 2 introduce un aspetto molto interessante, ovvero la possibilità di aggiungere comportamenti (behaviors) agli oggetti base (ad esempio posso aggiungere un comportamento Platform-Movement ad un oggetto di tipo sprite e, mandando in esecuzione il progetto vederlo muovere da subito alla pressione dei tasti di movimento del cursore e saltare premendo la barra spaziatrice - naturalmente ogni aspetto del behavior è configurabile - e ancora posso aggiungere ad altri oggetti sprite il comportamento Solid per far sì che il mio sprite giocatore, dotato di Platform-Movement, si fermi automaticamente andandoci a sbattere contro. Tutto questo senza aver scritto una sola riga di codice).

Quindi? se sono così fantastici perché passare a Godot dove, per ogni cosa che voglio realizzare, devo scrivere tonnellate di righe di codice?

Anzitutto perché, come detto in principio, la possibilità di entrare nel merito del codice offre una potenza non paragonabile agli altri strumenti, e secondariamente, perché se i componenti sviluppati per gli strumenti citati non dovessero calzare perfettamente con le nostre esigenze, dovremmo modificare (se disponibile il codice nel caso di ClickTeam Fusion 2.5, mentre nel caso di Construct 2 i sorgenti sono tutti disponibili) o addirittura riscrivere i componenti in questione.

Questo, nel caso di Construct 2, ci costringerà ad imparare a programmare in javascript (più precisamente ecmascript) che è il linguaggio che sta alla sua base mentre, nel caso di ClickTeam Fusion 2.5, dovremo partire con lo scrivere il componente in C++ (comunque in quanto è l'interfaccia base), quindi dovremo tradurlo in java se vorremo utilizzare il componente su android, in object-c se vorremo utilizzarlo su ios o mac, in javascript se vorremo utilizzarlo per l'esportatore in html5, in actionscript se vorremo esportare in flash, etc. 

Tutto molto bello, ma una vera babilonia, con tutto quello che ne può derivare (non è detto che le funzioni che andiamo ad utilizzare siano presenti allo stesso modo su tutti questi linguaggi, portando ad inevitabili compromessi).

Questo progetto, davvero ambizioso, vuole dare la possibilità allo sviluppatore di aggiungere dei nodi di tipo behavior alle scene che si stanno creando, in modo da ridurre all'essenziale la quantità di codice da scrivere (focalizzando l'attenzione più al game design che alla scrittura del codice in sè).

I punti cardine del progetto saranno:
  - uso del solo GDScript per il codice dei nodi behavior (un solo linguaggio che è lo stesso usato per scrivere il gioco)
  - tutto free e opensource (chiunque può mettere mano al codice per adattarlo alle proprie necessità - ognuno è *invitato* a pubblicare eventuali bugfix alla comunità)
  - ogni nodo comportamento dovrà essere aggiunto come sottonodo del nodo al quale vuole aggiungere il comportamento stesso
  - tutti i parametri di configurazione del comportamento dovranno essere esposti (nessuno dovrà modificare il codice solo per variare i parametri)
  
Chiunque può unirsi al progetto in qualunque momento! maggiore è il numero di comportamenti che riusciamo a fornire e più veloce sarà la realizzazione dei prototipi!

Al di là dell'idea che può piacere o meno, come programmatore sono abbastanza arruginito... quindi ovunque vedete che ci siano margini di miglioramento in quello che scrivo (soprattutto in termini di performance) correggetemi tranquillamente!

Per qualsiasi informazione, domanda o idea vogliate proporre, scrivetemi! e mi raccomando di commentare il codice!

==========================================================

(translated with the google translator)

As the title briefly says, this project has the ambition to become the link between Godot and the tools for the development of videogames without coding (for example Construct 2/3, ClickTeam Fusion 2.5, etc.)

Being able to enter into the code of what is happening allows an otherwise unattainable power (of course, I'm not saying anything new), however being able to create a working prototype of the idea we have in mind in a few steps is something that raises the motivation and productivity at levels never seen before (this is where the previously mentioned tools are placed).

As an example, from now on, I will only refer to Construct 2 and ClickTeam Fusion 2.5.

Both these products have - as it should be - a development environment heavily focused on their characteristics (for example, both have a tool, more or less valid, for editing images that make up sprites, which allows you to create very prototypes quickly).
Both have a drag-and-drop approach, both as regards the positioning of objects in the work area, and as regards the writing of the "code".

While ClickTeamFusion 2.5 has a series of exporters (purchased separately) in order to publish their work on various platforms in native code, Construct 2 only produces HTML5 games (so to be able to bring them on the various platforms then special wrappers, such as nwjs for desktop or cordova for furniture.

The strength of these tools is * not only * in providing, basically, a great set of tools ready to use, to be added to the scene, that fit together to produce, quickly, something working, but especially in the possibility of creating and adding new ones (both have behind the very lively communities that have really produced many additional components).

Moreover Construct 2 introduces a very interesting aspect, that is the possibility of adding behaviors to basic objects (for example I can add a Platform-Movement behavior to a sprite type object and, by running the project, see it move immediately to the pressure of the cursor movement keys and jump by pressing the space bar - of course every aspect of the behavior is configurable - and I can add to other sprite objects the Solid behavior so that my sprite player, equipped with Platform-Movement, will stop automatically going to run into it, all without writing a single line of code).

Then? if they are so fantastic why go to Godot where, for everything I want to do, I have to write tons of lines of code?

First of all because, as stated in the beginning, the possibility of entering into the merits of the code offers a power not comparable to other instruments, and secondly, because if the components developed for the instruments mentioned do not fit perfectly with our needs, we should modify (if code available in the case of ClickTeam Fusion 2.5, while in the case of Construct 2 the sources are all available) or even rewrite the components in question.

This, in the case of Construct 2, will force us to learn to program in javascript (more precisely ecmascript) which is the language that is at its base while, in the case of ClickTeam Fusion 2.5, we will start with writing the component in C ++ (however as it is the basic interface), so we will have to translate it in java if we want to use the component on android, in object-c if we want to use it on ios or mac, in javascript if we want to use it for the exporter in html5, in actionscript if we want export to flash, etc.

All very beautiful, but a real Babylon, with all that may derive from it (it is said that the functions we are going to use are present in the same way on all these languages, leading to inevitable compromises).

This project, really ambitious, wants to give the developer the possibility to add behavioral nodes to the scenes that are being created, in order to reduce to the essential the amount of code to be written (focusing the attention more on game design than on the writing the code itself).

The key points of the project will be:
  - use of the GDScript only for the code of the behavior nodes (a single language that is the same used to write the game)
  - all free and opensource (anyone can put his hand to the code to adapt it to their needs - everyone is * invited * to publish any bugfixes to the community)
  - each behavior node must be added as a sub-node of the node to which the behavior is to be added
  - all the configuration parameters of the behavior will have to be exposed (nobody will have to modify the code just to change the parameters)

Anyone can join the project at any time! the greater the number of behaviors we can provide, the faster the prototyping will be!

Beyond the idea that can like it or not, as a programmer I'm pretty rusty ... so wherever you see that there are room for improvement in what I write (especially in terms of performance) correct me quietly!

For any information, question or idea, please, write to me! and I recommend to comment on the code!
