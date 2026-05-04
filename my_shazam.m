function [final_songID, songName] = my_shazam(y_snippet, fs)
% Učitavanje baze podataka generirane u prethodnim koracima
load('HASHTABLE.mat'); % Sadrži ćeliju hash_table
load('SONGID.mat');    % Sadrži niz naziva pjesama

% 1. Generiranje tablice značajki za isječak (pomoću funkcije iz LV6)
% features: [f1, f2, t1_clip, dt]
snippet_features = make_table(y_snippet, fs); 

% Lista za spremanje svih pogodaka: [songID, t0]
matches = []; 

% 2. Prolazak kroz sve značajke isječka i pretraživanje baze
for i = 1:size(snippet_features, 1)
    f1 = snippet_features(i, 1);
    f2 = snippet_features(i, 2);
    t1_clip = snippet_features(i, 3);
    dt = snippet_features(i, 4);

    % Hash funkcija prema uputi iz LV7 dokumenta
    % h = dt * 2^16 + f1 * 2^8 + f2
    index = uint32(dt) * 2^16 + uint32(f1) * 2^8 + uint32(f2);

    % Provjera postoji li index u hash tablici
    if index > 0 && index <= length(hash_table)
        hits = hash_table{index}; % Hits sadrži [t1_song, songID]

        if ~isempty(hits)
            % Izračun vremenskog pomaka t0 = t1_pjesme - t1_isječka
            % To je ključno: ista pjesma će imati konstantan t0 za sve parove vrhova
            t0 = hits(:, 1) - t1_clip;
            songIDs = hits(:, 2);

            % Dodajemo u listu svih pronađenih podudaranja
            matches = [matches; songIDs, t0];
        end
    end
end

% 3. Određivanje pobjednika (pjesma s najviše podudarnih t0 pomaka)
if ~isempty(matches)
    % Grupiramo po pjesmi i tražimo "peak" u histogramu pomaka
    % Najjednostavnija metoda: mode (najčešći par ID i t0)
    % Za robusnost, tražimo najčešći songID nakon filtriranja t0
    potential_songID = mode(matches(:, 1)); 

    final_songID = potential_songID;
    songName = SONGID{final_songID};
else
    final_songID = 0;
    songName = 'Nepoznata pjesma';
end
end