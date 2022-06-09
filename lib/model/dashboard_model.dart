import 'package:scoped_model/scoped_model.dart';
import 'package:smart_bell/util/SessionManager.dart';

class DashboardModel extends Model{
  int _selectedIndex=0;

  int get selectedIndex =>_selectedIndex;

  updateIndex(index){
    _selectedIndex=index;
    notifyListeners();
  }
}