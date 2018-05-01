
// actual limits are 1 and 1.5, but let's not be too edgy
float dragon_max_height = 1.05;
float dragon_max_width = 1.55;

int canvas_width = 1800;
int canvas_height = 800;

PVector dragon_begin = new PVector (0.33, 0.33);
PVector dragon_end = new PVector(1.33, 0.33);

class DragonNode {
  PVector point;
  PVector animatefrom;
  DragonNode parent, left, right;
  DragonNode(PVector p, DragonNode par, DragonNode l, DragonNode r) {
     point=p;
     parent=par;
     left=l;
     right=r;
  }
  DragonNode(PVector p) {
    point=p;
     parent=null;
     left=null;
     right=null;
  }
};



class DragonTree {
  DragonNode root;
  DragonNode special_left;
  DragonNode special_right;
  
  int max_level = 0;
  ArrayList<ArrayList<DragonNode> > levels = new ArrayList();
  
  DragonTree() {
    special_left = new DragonNode(dragon_begin, null, null, null);
    special_right = new DragonNode(dragon_end, null, null, null);
    special_left.right = special_right;
    special_right.left = special_left;
    root = null;
  }
  
  DragonNode GetNextPoint(DragonNode first, DragonNode second, int parity) {
     PVector line = new PVector((second.point.x - first.point.x)/sqrt(2), (second.point.y - first.point.y)/sqrt(2));
     line.rotate(parity * PI/4);
     line.add(first.point);
     return new DragonNode(line);
  }
  
  //DragonNode InOrderLeft(DragonNode node) {
  //  return null;
  //}
  
  DragonNode InOrderRight(DragonNode node) {
    if (node == special_right) return null;
    if (node == special_left) {
       if (root == null) return special_right;
       DragonNode curr = root;
       while (curr.left != null) curr = curr.left;
       return curr;
    }
    
    DragonNode curr = node;
    if (curr.right != null) {
      curr = curr.right;
      while (curr.left != null) curr = curr.left;
    } else {
      while(true) {
        if (curr.parent != null) {
          if (curr.parent.left == curr) {
            curr = curr.parent;
            break;
          } else {
            curr = curr.parent;
          }
        } else {
          curr = special_right;
          break;
        }
      }
    }
    
    return curr;
  }
  
  void NextLevel() {
    levels.add(new ArrayList<DragonNode>());
    if (root == null) {
      root = GetNextPoint(special_left, special_right, 1);
      
      levels.get(0).add(root);
        
      max_level = 1;
    } else {      
      DragonNode curr = special_left;
      int parity = 1;
      while(curr != special_right) {
        DragonNode leftone = curr;
        DragonNode rightone = InOrderRight(curr);
        
        DragonNode newone = GetNextPoint(leftone, rightone, parity);
        parity = -parity;
        levels.get(max_level).add(newone);
        
        if (leftone == special_left) {
          newone.parent = rightone;
          rightone.left = newone;
        } else if (rightone == special_right) {
          newone.parent = leftone;
          leftone.right = newone;
        } else if (leftone.right == null) {
          newone.parent = leftone;
          leftone.right = newone;
        } else if (rightone.left == null) {
          newone.parent = rightone;
          rightone.left = newone;
        } else {
            
        }
        
        curr = rightone;
      }
    }
  }
  
  void DrawWhole() {
      DragonNode previous = special_left;
      DragonNode current = InOrderRight(previous);
      
      while (current != null) {
        float startx = previous.point.x / dragon_max_width * canvas_width;
        float starty = previous.point.y / dragon_max_height * canvas_height;
        float endx = current.point.x / dragon_max_width * canvas_width;
        float endy = current.point.y / dragon_max_height * canvas_height;
        line(startx, starty, endx, endy); //<>//
        previous = current;
        current = InOrderRight(previous);
      }
  }
  
};

DragonTree tree = new DragonTree();

void setup() {
  size(1800, 800);  
}

int iter=0;
void draw() {
  background(0);
  stroke(255);
  strokeWeight(1);
  
  if (iter != 0)
    tree.NextLevel();
  tree.DrawWhole();
  
  delay(500);
  iter++; 
}
