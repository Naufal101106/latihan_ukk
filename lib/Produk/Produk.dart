import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/Produk/Insert.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formkey = GlobalKey<FormState>();

  Future<List<Map<String, dynamic>>> fetchdata() async {
    try {
      final response = await supabase.from('produk').select('NamaProduk, Harga, Stok');

      return response as List<Map<String, dynamic>>;
    }catch (e) {
      print("Error: $e");
      return [];
    }
  }
  
  void deleteProduk(BuildContext context, String namaProduk) async {
  try {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await supabase.from('produk').delete().eq('NamaProduk', namaProduk);
      setState(() {}); // Memperbarui UI setelah penghapusan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil dihapus'), backgroundColor: Colors.green),
      );
    }
  } catch (e) {
    print('Error deleting product: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menghapus produk!'), backgroundColor: Colors.red),
    );
  }
}

  void showEditPopup(BuildContext context, Map<String, dynamic> item) {
    TextEditingController namaController =
        TextEditingController(text: item['NamaProduk']);
    TextEditingController hargaController = 
        TextEditingController(text: item['Harga'].toString());
    TextEditingController stokController = 
        TextEditingController(text: item['Stok'].toString());

      showDialog(
        context: context, 
        builder: (context) {
          return Form(
            key: _formkey,
            child: AlertDialog(
              title: Text('Edit Produk'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(label: Text('Nama Produk')),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Nama Produk!';
                        }
                        return null;
                      },
                    ),
            
                    TextFormField(
                      controller: hargaController,
                      decoration: InputDecoration(label: Text('Harga')),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Harga!';
                        }
                        return null;
                      },
                    ),
            
                    TextFormField(
                      controller: stokController,
                      decoration: InputDecoration(label: Text('Stok')),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Stok!';
                        }
                        return null;
                      },
                    )
                ],
              ),
            
              actions: [
                TextButton(
                  onPressed: () =>Navigator.pop(context), 
                  child: Text('Batal'),
                  ),
            
                  ElevatedButton(
                    onPressed: () async {
                      await supabase.from('produk').update({
                        'NamaProduk' : namaController.text,
                        'Harga' : int.parse(hargaController.text),
                        'Stok' : int.parse(stokController.text),
                      }).eq('NamaProduk', item['NamaProduk']);

                      if (_formkey.currentState!.validate()) {
                        Navigator.pop(context);
                        setState(() {
                          
                        });
                      }
                    }, 
                    child: Text('simpan') 
                    )
              ],
            ),
          );
        }
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context, 
                MaterialPageRoute(builder: (context) => Insert())
            );
            if (result == true);
            Produk();
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 3, 186, 247),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.add, color: Colors.white,)],
          ),
        ),
      ),

      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(left: 28),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder(
        future: fetchdata(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Data Tidak Ditemukan'));
          } else {
            final List<Map<String, dynamic>> data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      item['NamaProduk'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga : Rp ${item['Harga']}'),
                        Text('Stok : ${item['Stok']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue,),
                          onPressed: () => showEditPopup(context, item),
                          ),
                        
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red,),
                          onPressed: () => deleteProduk(context, item['NamaProduk']),
                          )
                        
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      ),
    );
  }
}