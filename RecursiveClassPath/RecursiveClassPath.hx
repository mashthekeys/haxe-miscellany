#if neko
/**
	Macro Utility RecursiveClassPath
	
	This compilation utility recurses through a folder, adding all folders
	beginning with an upper-case ASCII letter to the class path list.
	
	To invoke it, add this to your command line when you compile:
	--macro "RecursiveClassPath.add('/the/include/path')"
	
	Tested in Haxe 2.10.
	
	Heavily based on haxe.macro.Compiler.include, so:
	Copyright (C)2005-2013 Haxe Foundation
**/
import haxe.macro.Context;
import haxe.macro.Compiler;

class RecursiveClassPath {
	public static function addVerbose( classPathsRoot : String, ?ignore : Array<String> ) {
        trace("Initial Class Paths: [\n" + Context.getClassPath().join("\n") + "\n]");
		add( classPathsRoot, ignore, true );
        trace("Updated Class Paths: [\n" + Context.getClassPath().join("\n") + "\n]");
    }
	/**
		Recurses through a folder, adding all folders beginning with an
		upper-case ASCII letter to the class path list. 
		
		A second optional parameter is a list of folders to exclude.
	**/
	private static function add( classPathsRoot : String, ?ignore : Array<String>, verbose = false ) {
	    var skip = if(null == ignore) {
    	    function(c) return false;
	    } else {
        	function(c) return Lambda.has(ignore, c);
    	}
    
	    // normalize class path
		classPathsRoot = StringTools.replace(classPathsRoot, "\\", "/");
	    if(StringTools.endsWith(classPathsRoot, "/")) {
        	classPathsRoot = classPathsRoot.substr(0, -1);
    	}

	    if( !neko.FileSystem.exists(classPathsRoot) || !neko.FileSystem.isDirectory(classPathsRoot) ) {
	    	Context.error("Cannot read from class path root '"+classPathsRoot+"'", Context.currentPos());
    	    return;
    	}

        Compiler.addClassPath(classPathsRoot);
        if (verbose) trace('Compiler.addClassPath("'+classPathsRoot+'")');
            
	    for( file in neko.FileSystem.readDirectory(classPathsRoot) ) {
    	   	var path = classPathsRoot + "/" + file;
        	var firstLetter = file.charAt(0);

	       	if (neko.FileSystem.isDirectory(path) 
	       			&& !skip(path) 
			       	&& firstLetter.toLowerCase() != firstLetter.toUpperCase() 
	    		   	&& firstLetter == firstLetter.toUpperCase() 
	    	) {
    	   	     add(path, ignore);
       		}
    	}
	}
}
#end