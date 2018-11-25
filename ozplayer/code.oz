
local
% See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] silence(duration:D) then silence(duration:D)
      [] note(name:Name octave:Octave sharp:Boolean duration:Dur instrument:none) then
	 note(name:Name octave:Octave sharp:Boolean duration:Dur instrument:none)
      [] H|T then if T == nil then  {NoteToExtended H} | nil %chord
		  else {NoteToExtended H} | {NoteToExtended T} end
      [] Atom then
	 case {AtomToString Atom}
	 of [_] then note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
	 [] [N O] then
	    note(name:{StringToAtom [N]}
		 octave:{StringToInt [O]}
		 sharp:false
		 duration:1.0
		 instrument: none)
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   fun {PartitionToTimedList Partition}%exemple de partition:[a b c duration(seconds:30 [a b duration(seconds:20 [a b [c d]]) c]) d e]
      case Partition of nil then nil
      [] H|T then
	 case H of duration(seconds:Dur Partion) then {List.append {Duration Dur Partion} {PartitionToTimedList T}} %NEW MODIFS.
%On rajoute de la complexité avec le append, mais on a pas le choix car nos transformation renvoient des listes or,
%on ne veut pas que celle ci soient interpretées comme des extended chords dans la partition. J'ai cherché d'autres méthodes à complexités
%plus basses, mais elles considérait l'ensemble d'éléments à insérer comme un seul et unique.
	 [] strech(factor:Factor Partion) then {List.append {Strech Factor Partion}  {PartitionToTimedList T}}
	 [] drone(note:NoteChord amount:Natural) then {List.append {Drone NoteChord Natural} {PartitionToTimedList T}}
	 [] transpose(semitones:Integer Partition )then {List.append {Transpose Seminotes Partition} {PartitionToTimedList T}}
	 else {NoteToExtended H} | {PartitionToTimedList T}
	 end
      end
   end
  %-------------------------------------------------------------------------------
  %retourne la partition prise en argument avec comme durée totale Secondes (en sec.)
   %Secondes doit être un float sinon la comparaison Somme==Secondes plante.
   fun {Duration Secondes Partition} % /!\ doit retourner un liste qu'on va append!!!!
      local
	 Facteur
	 Somme
	 fun {Parcours Partition Acc}%additionne tout les temps
	    case Partition of H|T then %étape2:on parcourt la timedList afin de savoir la durée initale de la partition
	       if {List.is H} then {Parcours T Acc+{Parcours H 0.0}}%parcour d'une extended chord.
	       else
		  {Parcours T Acc+H.duration}
	       end
	    [] nil then Acc
	    end
	 end
      in %étape1:on appelle PartitionToTimedList pour mettre tout en timedList.
	 Somme={Parcours {PartitionToTimedList Partition} 0.0}
	 if {Int.is Somme} then %etape 3changement de somme et Secondes en float car l'opérateur '/' ne fonctionne qu'avec ce type.
	    if {Int.is Secondes}then Facteur={Int.toFloat Secondes}/{Int.toFloat Somme}
	    else Facteur=Secondes/{Int.toFloat Somme}
	    end
	 elseif {Int.is Secondes} then
	    Facteur={Int.toFloat Secondes}/Somme %etape4: on calcule le rapport Tfinal/Tinitial
	 else
	    Facteur=Secondes/Somme
	 end
	 if Somme == Secondes then Partition
	 else
	    {Strech Facteur Partition}%etape5, on retourne une liste modifiée.
	 end
      end
   end


  %-------------------------------------------------------------------------------

   %crashe quand Fact\= de float même parsing dans le local.
   fun {Strech Factor Parti}
      local
	 Partition={PartitionToTimedList Parti}
      in
	 case Partition of nil then nil
	 [] H|T then
	    case H of note(name:Name octave:Octave sharp:Boolean duration:Dur instrument:Instru)
	    then note(name:Name octave:Octave sharp:Boolean duration:Dur*Factor instrument:Instru)|{Strech Factor T}%faire gaffe avec'*' car si int*float->crash
	    [] U|V then {Strech Factor H}|{Strech Factor T}
	    end
	 end
      end
   end



  % %-------------------------------------------------------------------------------

  % 	 fun {Drone Note Amount}
  % 	 end

  % %-------------------------------------------------------------------------------

  % 	 fun {Transpose Seminotes Partition}
  % 	 end

  %-------------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 fun {Mix P2T Music}

	    {Project.readFile 'wave/animaux/cow.wav'}
	 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 Music = {Project.load 'joy.dj.oz'}
	 Start

  % Uncomment next line to insert your tests.
  % \insert 'tests.oz'
  % !!! Remove this before submitting.
      in
	 Start = {Time}

  % Uncomment next line to run your tests.
  % {Test Mix PartitionToTimedList}

  % Add variables to this list to avoid "local variable used only once"
  % warnings.
	 {ForAll [NoteToExtended Music] Wait}

  % Calls your code, prints the result and outputs the result to `out.wav`.
  % You don't need to modify this.
	 {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}

  % Shows the total time to run your code.
	 {Browse {IntToFloat {Time}-Start} / 1000.0}
      end
