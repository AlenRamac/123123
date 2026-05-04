function add_to_hash(lista_pjesama, dir_name)
% 1. Inicijalizacija ili učitavanje postojeće baze
if exist('HASHTABLE.mat', 'file') && exist('SONGID.mat', 'file')
    load('HASHTABLE.mat');
    load('SONGID.mat');
else
    % Ako ne postoji, kreiramo praznu ćeliju (hash_table) i listu imena
    % Veličina 2^24 je dovoljna za hash (8 bita f1 + 8 bita f2 + ostalo dt)
    hash_table = cell(1, 2^24); 
    SONGID = {};
end

% 2. Prolazak kroz svaku pjesmu iz ulazne liste
for i = 1:length(lista_pjesama)
    trenutna_pjesma = lista_pjesama{i};
    fprintf('Obrađujem: %s...\n', trenutna_pjesma);

    % Ažuriranje liste SONGID i dobivanje novog ID-a
    SONGID{end+1} = trenutna_pjesma;
    songid = length(SONGID);

    % Učitavanje pjesme
    [y, fs] = audioread(fullfile(dir_name, trenutna_pjesma));

    % Generiranje tablice značajki pomoću funkcije iz LV6
    % features: [f1, f2, t1, dt]
    features = make_table(y, fs); 

    % 3. Popunjavanje hash tablice[cite: 1]
    for j = 1:size(features, 1)
        f1 = uint32(features(j, 1));
        f2 = uint32(features(j, 2));
        t1 = features(j, 3);
        dt = uint32(features(j, 4));

        % Hash funkcija: h = dt*2^16 + f1*2^8 + f2[cite: 1]
        index = dt * 2^16 + f1 * 2^8 + f2;

        % Pripazite da je indeks unutar granica i nije nula
        if index == 0, index = 1; end
        if index > length(hash_table), continue; end

        % Spremanje (t1, songid) na lokaciju index
        % Koristimo separate chaining (dodajemo u postojeći niz na toj lokaciji)
        hash_table{index} = [hash_table{index}; t1, songid];
    end
end

% 4. Spremanje baze na disk[cite: 1]
save('HASHTABLE.mat', 'hash_table', '-v7.3'); % -v7.3 zbog veličine datoteke
save('SONGID.mat', 'SONGID');
end