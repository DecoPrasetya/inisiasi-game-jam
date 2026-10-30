# Genre: Tower Defense, Endless Game, Time and Resource Management, Strategy, 

# Deskripsi:

Berlatarkan di sebuah hutan yang jauh dari pemukiman, terdapat seorang yang baru saja membeli rumah yang berada di tengah hutan belantara. hutan tersebut sangat banyak sekali hewan hewan dan “monster”.  Mereka tidak suka dengan kehadiran manusia di hutan mereka, jadi ketika malam hari mereka akan berusaha “mengusir” manusia tersebut. makin lama manusia tersebut tinggal, makin banyak dan mengerikan hewan dan “monster” yang akan datang. Manusia yang datang tersebut bukan manusia sembarangan. manusia tsb membawa bibit tanaman untuk membantu melindunginya dari hewan dan monster

# Gameplay:

**Peran Player:** ***manusia*** yang menanam ***tanaman-tanaman*** untuk melindungi ***rumah*** dari serangan para ***hewan(monster)***.  
**Mapping:** rumah berada ditengah dan dikelilingi oleh lahan yang akan ditanami. untuk bentuk mappingnya membentuk belah ketupat seperti coc. enemy akan menyerang dari 4 sisi.  
**Skenario:** semakin banyak hari yang dilalui maka semakin banyak variasi dan jumlah hewan(monster) yang berdatangan. ketika hewan(monster) berhasil dibunuh, maka akan menghasilkan sumber daya yang dapat digunakan untuk membeli atau meningkatkan tanaman baru 

- ## Tanaman

  **Atribut:** peran(role), skill passive, biaya (cost), health point ( poin nyawa), rarity(kelangkaan) 

**Role**: “Damage Dealer”, “Supporter”, “Defender”. Tanaman hanya terikat oleh satu role. spesifikasi dalam tiap role meliputi  
**a. Damage Dealer**  
	tanaman yang memiliki **role Damage Dealer** setidaknya memberikan damage ke hewan sebanyak 1 (selain tanaman dengan role damage dealer tidak boleh memberikan damage ke hewan).   
Atribut dari tanaman Damage Dealer antara lain:

1. Kerusakan Per-Detik (Damage per Second)  

   Setiap tanaman dengan role Damage Dealer harus memiliki damage konstan. harus jelas dan bisa dimodifikasi tergantung peningkatan karakter(buff)/penurunan karakter(debuff). 

2. Poin nyawa (Health Point)

   Poin nyawa untuk memastikan apakah tanaman masih hidup. harus jelas dan bisa dimodifikasi  buff debuff

3. Kelangkaan(rarity)

   Ini sebagai pelabelan dimana tanaman ini seberapa sulit mendapatkan atau seberapa mahal mendapatkan

   

	**b. Supporter**

Tanaman dengan role Suporter setidaknya memberikan peningkatan (buff) kepada tanaman lain atau debuff ke hewan. Hanya tanaman dengan role Suporter yang boleh melakukan hal hal tersebut.  
Atribut dari tanaman Supporter antara lain:

1. Buff or Debuff

   Setiap tanaman Supporter setidaknya memiliki skill untuk buff ke tanaman atau debuff ke hewan. 

2. Poin nyawa (Health Point)

   Poin nyawa untuk memastikan apakah tanaman masih hidup. harus jelas dan bisa dimodifikasi  buff debuff

3. Kelangkaan(rarity)

   Ini sebagai pelabelan dimana tanaman ini seberapa sulit mendapatkan atau seberapa mahal mendapatkan

   

	**c. Defender**  
		Tanaman dengan role Defender Harus memiliki hp diatas rata rata dibanding rata rata tanaman lain. Keunggulan lainnya adalah hanya tanaman defender yang boleh melakukan crowd controll.

1. Crowd Control (CC)  
   	Sebenernya untuk tanaman Defender, CC bersifat opsional, cuman hanya tanaman Defender yang boleh melakukan CC.  
2. Poin Nyawa (Health Point)

   Poin nyawa untuk memastikan apakah tanaman masih hidup. harus jelas dan bisa dimodifikasi  buff debuff. Dalam tanaman Defender, nilai awal HP harus diatas rata rata.

3. Kelangkaan(rarity)

   Ini sebagai pelabelan dimana tanaman ini seberapa sulit mendapatkan atau seberapa mahal mendapatkan.

- ## Hewan / Monster

  **Atribut:** Health Point, Tipe Serangan (Jarak Dekat, Jarak Jauh, Tidak Menyerang), Deskripsi Kemampuan/Skill  
- Health Point

  Poin nyawa untuk memastikan apakah hewan/monster masih hidup. harus jelas dan bisa dimodifikasi buff debuff.

- Tipe Serangan

  Tipe serangan adalah range serangan dari suatu hewan. apakah dia jarak dekat maupun jarak jauh.

- Deskripsi kemampuan  
  	Setiap hewan harus memiliki deskripsi serangan yang jelas, bukan hanya soal tipe serangan, tapi harus lebih detail

- ## Rumah

  **Atribut:** Health Point, Space Tanaman, Maksimal Level Tanaman  
- Health Point

  Poin nyawa untuk rumah untuk menentukan apakah game masih bisa dilanjutkan atau tidak. harus jelas dan bisa dimodifikasi buff. HP rumah tidak bisa di debuff.

- Space Tanaman  
  	Semakin tinggi level rumah, semakin banyak tanaman yang bisa di tanaman.  
- Maksimal LVL Tanaman .

  Level dari rumah menjadi batas seberapa banyak tanaman bisa ditingkatkan. Misalkan rumah level 4, maksimal level tanaman yang ada tidak boleh melebihi level 4\.

  