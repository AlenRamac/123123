clear;

% Skripta za inicijalizaciju i generiranje baze podataka
dir_name = 'songs\'; % Ime direktorija u kojemu se nalaze .mp3 datoteke

% Dobivanje liste svih .mp3 datoteka u direktoriju
% (Pretpostavka je da imate pomoćnu funkciju getMp3List ili koristite dir)
pjesme = dir(fullfile(dir_name, '*.mp3'));
lista_pjesama = {pjesme.name};

% Pozivanje funkcije za dodavanje u hash tablicu
add_to_hash(lista_pjesama, dir_name);

fprintf('Baza podataka je uspješno kreirana i spremljena.\n');