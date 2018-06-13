# Godot-Engine-3.0-Behavior-Nodes
The link between Godot and no-coding tools for video games creation

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

========================================================================================================================

TO DO: Aggiungere traduzione in lingua inglese
