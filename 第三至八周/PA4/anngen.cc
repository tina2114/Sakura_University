//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

#include "cool-tree.h"
#include "cool-io.h"

#include "anngen.h"
 

// We emit a # before ANN to make SPIM happy
char* ann = "#ANN";

extern Program ast_root; 
void emitAnnotations(ostream &os) {

  // bhackett: get_classes does not seem to exist
  /*

  Classes classes = ast_root->get_classes ();

  // Dump first the information about the built-in classes
  os << ann << "(COOLCLASS, \"Object\", \"_no_class\")\n";
  os << ann << "(COOLMETHOD, \"Object\", \"abort\", \"Object\")\n";
  os << ann << "(COOLMETHOD, \"Object\", \"type_name\", \"String\")\n";
  os << ann << "(COOLMETHOD, \"Object\", \"copy\", \"SELF_TYPE\")\n";
  os << ann << "(COOLCLASS, \"String\", \"Object\", \"Int\", \"_prim_slot\")\n";
  os << ann << "(COOLMETHOD, \"String\", \"length\", \"Int\")\n";
  os << ann << "(COOLMETHOD, \"String\", \"concat\", \"String\", \"String\")\n";
  os << ann << "(COOLMETHOD, \"String\", \"substr\", \"Int\", \"Int\", \"String\")\n";
  os << ann << "(COOLCLASS, \"Bool\", \"Object\", \"_prim_slot\")\n";
  os << ann << "(COOLCLASS, \"Int\", \"Object\", \"_prim_slot\")\n";
  os << ann << "(COOLCLASS, \"IO\", \"Object\")\n";
  os << ann << "(COOLMETHOD, \"IO\", \"out_string\", \"String\", \"SELF_TYPE\")\n";
  os << ann << "(COOLMETHOD, \"IO\", \"out_int\", \"Int\", \"SELF_TYPE\")\n";
  os << ann << "(COOLMETHOD, \"IO\", \"in_string\", \"String\")\n";
  os << ann << "(COOLMETHOD, \"IO\", \"in_int\", \"Int\")\n";
  
  // Scan all classes
  for(int i = classes->first(); classes->more(i); i = classes->next(i)) {
    Class__class *cl = classes->nth(i);

    // Start emitting the annotation for the class: name, parent, attributes
    // with their types
    os << ann << "(COOLCLASS, \"" << cl->get_name() << "\","
       << "\"" << cl->get_parent() << "\"";
    // Now we must list the attributes, in the order in which they appear
    
    Features features = cl->get_features ();
    
    for(int i = features->first(); features->more(i); i = features->next(i)) {
      Feature_class *feature = features->nth(i);
      attr_class *attribute = dynamic_cast<attr_class*>(feature);
      if(attribute) {
        // It really was an attribute
        os << ", \"" << attribute->get_type_decl () << "\"";
      }
    }
    os << ")\n";

    // Now we must list the methods
    for(int i = features->first(); features->more(i); i = features->next(i)) {
      Feature feature = features->nth(i);
      method_class *method = dynamic_cast<method_class*>(feature);
      if(method) {
        // It really was a method
        os << "  " << ann << "(COOLMETHOD, \"" << cl->get_name() << "\", \""
           << method->get_name () << "\"";
        // We must list the types of the formals
        Formals formals = method->get_formals();
        for(int f = formals->first(); formals->more(f); f = formals->next(f)) {
          os << ", \"" << formals->nth(f)->get_type_decl () << "\"";
        }
        // Now the return type
        os << ", \"" << method->get_return_type() << "\")\n";
      }
    }
    
  }

  */ // bhackett
}
 
