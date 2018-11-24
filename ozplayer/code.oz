
local
   % See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note} % exemple de partition:[a b c duration(seconds:30 [a b duration(seconds:20 [a b [c d]]) c]) d e]
      case Note
      of Name#Octave then
	 note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      
      [] silence(duration:D) then silence(duration:D)
      [] note(name:Name octave:Octave sharp:Boolean duration:Dur instrument:none) then
	 note(name:Name octave:Octave sharp:Boolean duration:Dur instrument:none) % j'ai mis les Dur et Boolean car si on recoit une duration on doit le faire
      [] H|T then if T == nil then  {NoteToExtended H} | nil %chord
		  else {NoteToExtended H} | {NoteToExtended T} end
      [] duration(seconds:Dur Parti) then
	 {Duration Dur Parti}
      [] Atom then
	 case {AtomToString Atom}
	 of [_] then
	    note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
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

   fun {PartitionToTimedList Partition}
      case Partition of
	 nil then nil
      [] H|T then {NoteToExtended H} | {PartitionToTimedList T}
      end
   end

 %-------------------------------------------------------------------------------
   %retourne la partition prise en argument avec comme durée totale Secondes (en sec.)
   fun {Duration Secondes Partition}
      local
	 Rapport
	 Somme
	 fun {Parcours Partition Acc}%additionne tout les temps
	    case Partition of H|T then %étape2:on parcourt la timedList afin de savoir la durée initale de la partition
	       if {List.is H} then {Parcours T Acc+{Parcours H Acc}}%parcour d'une extended chord.
	       else
		  {Parcours T Acc+H.duration}% /!\ je vais me chopper un erreur ici car il y aura des extended chords
	       end
	    [] nil then Acc
	    end
	 end
      in %étape1:on appelle PartitionToTimedList pour mettre tout en timedList.
	 Somme={Parcours {PartitionToTimedList Partition} 0}
	 Rapport=Secondes div Somme %etape3: on calcule le rapport Tfinal/Tinitial
	 if Somme\= Secondes then {Strech Partition Rapport}
	 end		  	  
      end
   end
   

 %-------------------------------------------------------------------------------

   fun {Strech Factor Partition}
   end

 %-------------------------------------------------------------------------------

   fun {Drone Note Amount}
   end

 %-------------------------------------------------------------------------------

   fun {Transpose Seminotes Partition}
   end

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