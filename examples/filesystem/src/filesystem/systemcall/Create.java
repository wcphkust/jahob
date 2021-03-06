package filesystem.systemcall;

import filesystem.*;
import filesystem.inode.*;
import filesystem.buffercache.*;
import filesystem.util.*;
import filesystem.subsystem.*;

public class Create {
    
    public static FileDescriptor create(String pathname) {
        Inode inode = Namei.namei(pathname);
        
        if (inode != null)
            return null;
        
        inode = Ialloc.ialloc();
        inode.fileType = Inode.REGULAR;
        String dirname = dirname(pathname);
        Inode parent = Namei.namei(dirname);
        Directory dir = new Directory(parent);
        dir.add(new DirectoryEntry(inode.id, filename(pathname)));
        
        FileTableEntry fte = FileSystem.globalFileTable.alloc();
        fte.inode = inode;
        fte.offset = 0;
        
        FileDescriptor ufti = FileSystem.userFileTable.alloc();
        ufti.fileTableEntry = fte;
        fte.refCount++;
                
        return ufti;
    }
    
    private static String dirname(String pathname) {
        if (!pathname.startsWith("/"))
            throw new RuntimeException();
        
        String str = "";
        String parent = "/";
        StringTokenizer st = new StringTokenizer(pathname, "/");
        while (st.hasNext()) {
            parent += str;            
            str = st.next();            
        }
        
        return parent;
    }
    
    private static String filename(String pathname) {
        if (!pathname.startsWith("/"))
            throw new RuntimeException();
        
        String str = "/";
        String parent = null;
        StringTokenizer st = new StringTokenizer(pathname, "/");
        while (st.hasNext()) {
            parent = str;
            str = st.next();
        }
        
        return str;
    }
}