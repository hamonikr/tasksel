??          D      l       ?   d  ?   j  ?     Y     h  L  x  C  ?  I  	     S     p                          Usage:
tasksel install <task>
tasksel remove <task>
tasksel [options]
	-t, --test          test mode; don't really do anything
	    --new-install   automatically install some tasks
	    --list-tasks    list tasks that would be displayed and exit
	    --task-packages list available packages in a task
	    --task-desc     returns the description of a task
 Usage:
tasksel install <task>...
tasksel remove <task>...
tasksel [options]
	-t, --test          test mode; don't really do anything
	    --new-install   automatically install some tasks
	    --list-tasks    list tasks that would be displayed and exit
	    --task-packages list available packages in a task
	    --task-desc     returns the description of a task
 apt-get failed aptitude failed Project-Id-Version: tasksel
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2006-08-03 15:43+0800
Last-Translator: Eric Pareja <xenos@upm.edu.ph>
Language-Team: Tagalog <debian-tl@banwa.upm.edu.ph>
Language: tl
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=n>1;
 Pag-gamit:
tasksel install <task> - upang magluklok ng <task>
tasksel remove <task>  - upang magtanggal ng <task>
tasksel [options]; kung saan ang options ay kombinasyon ng:
	-t, --test··········modong testing; wala talagang gagawin
	-r, --required······magluklok ng lahat ng mga pakete na ang antas ay kailangan
	-i, --important     magluklok ng lahat ng mga pakete na ang antas ay mahalaga
	-s, --standard      magluklok ng lahat ng mga pakete na ang antas ay karaniwan
	-n, --no-ui     huwag ipakita ang UI; gamitin lamang kasama ng -r o madalas ng -i
	     --new-install   magluklok ng ilang mga task ng awtomatiko
	     --list-tasks    ilista ang mga task na ipapakita at lumabas
	     --task-packages ilista ang mga pakete na magagamit sa isang task
	     --task-desc      ibabalik ang paglalarawan ng isang task
 Pag-gamit:
tasksel install <task> - upang magluklok ng <task>...
tasksel remove <task>  - upang magtanggal ng <task>...
tasksel [options]; kung saan ang options ay kombinasyon ng:
	-t, --test··········modong testing; wala talagang gagawin
	-r, --required······magluklok ng lahat ng mga pakete na ang antas ay kailangan
	-i, --important     magluklok ng lahat ng mga pakete na ang antas ay mahalaga
	-s, --standard      magluklok ng lahat ng mga pakete na ang antas ay karaniwan
	-n, --no-ui     huwag ipakita ang UI; gamitin lamang kasama ng -r o madalas ng -i
	     --new-install   magluklok ng ilang mga task ng awtomatiko
	     --list-tasks    ilista ang mga task na ipapakita at lumabas
	     --task-packages ilista ang mga pakete na magagamit sa isang task
	     --task-desc      ibabalik ang paglalarawan ng isang task
 bigo ang pagtakbo ng apt-get bigo ang pagtakbo ng aptitude 