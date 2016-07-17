COMPILER_OPTIONS _max_process=2000;

PROGRAM divbattlearenazone;

 //v23
//======================================================================================================================

CONST
//COLOURS
green=127; green0=64;  white=63; white0=0;       fire1=175; fire0=128;
red=255;    cyan=239; cyan0=176;

SHADERANGE=63;
//STATE ENUMERATION
out=0;  show=1; action=2; exploding=3; boom=4;  reset=5; dead=6; respawn=7; ready=8;
onfire=9: onfoot=10; ascent=11; hopping=12; got_fuel=13;   got_shell=14;  got_nowt=15;
shot=16; shooting=17; running=18;   kamikazi=19;   reloading=20;




//FONT CODES
_#=0;
a#=1; b#=2; c#=3; d#=4; e#=5; f#=6; g#=7; h#=8; i#=9; j#=10;
k#=11; l#=12; m#=13; n#=14; o#=15; p#=16; q#=17; r#=18;
s#=19; t#=20; u#=21; v#=22; w#=23; x#=24; y#=25; z#=26;
excl#=27;  apos#=40;
n0#=30; n1#=31; n2#=32; n3#=33; n4#=34; n5#=35; n6#=36; n7#=37; n8#=38; n9#=39;
up#=41; dn#=42; lf#=43; rt#=44;

//playerstate enumerations


//======================================================================================================================


global

//---------------------------------------------------

GAMESTATE=-1;
//---------------------------------------------------



statetag[20]= "out",  "show", "action", "exploding", "boom", "reset", "dead",
              "respawn", "ready", "onfire", "on foot", "ascent", "hopping",
              "got_fuel", "got_shell", "got_nowt","shot","shooting", "running",
              "kamikazi";


IM_id[1];


color[2]= 63,127,239;


obj_count=0;
tank_count=0;;
box_count=0;;
shell_count=0;
frag_count;


ctank_graph[1];
cshell_graph[1];
file0;

fog=128;
scr_w=800;
scr_h=600;



scr_cx;
scr_cy;


clip=-40;

//keys
up[1]; dn[1]; lf[1]; rt[1]; ctrl[1]; fire[1];



//Object index names
SHELL[5];
TANK[1];
HULL[1];
TURRET[1];
SHAFT[1];
BARREL[1];
post[1];
dish[1];
 player[1];
obj_pwrshell[1];
obj_pwrfuel[1];

//Object process handles
tank_id[1];
SHELL_ID[5];
HULL_ID[1];
TURRET_ID[1];
SHAFT_ID[1];
BARREL_ID[1];
POST_id[1];
dish_id[1];
player_id[1];
shellpwr_id[1];
fuelpwr_id[1];

//STRUCTURES----------------------------------------STRUCTURES


struct m_dot[200]
ang,h;   cont;
end

struct m_line[200]
x[1];y[1];  z[1];
end



struct s_minishell[1]
part_id[1];
part[1];
end
//----------------------------

struct s_minifuel[1]
part_id[1];
part[1];
end
//----------------------------

struct body[1]
head,
arm_l,
arm_r,
torso,
leg_l,
leg_r,
head_id,
torso_id,
arm_l_id,
arm_r_id,
leg_l_id,
leg_r_id;
end
//----------------------------

struct score
fuel0;
ammo0;
bullets0;
tanks0;
shells[1];
fuel[1];
bullets[1];
tanks[1];
justKilled[1];
END  =30000,10,6,5,10,10, 30000,30000,0,0,0,0,0,0;
//----------------------------

struct cam[2]
distance;
posX;
posY;
posZ;
depth;
fov;
angle;
vx; vy; vz;
cx;
cy;
h,
w,
fog;
cosine;
sine;
END
//-----------------------------

struct obj[80]
vertex_count ;
edge_count;
face_count;
anglez;
anglex;
angley=0;
vel; vely;
col0;
X0; y0: z0;
posx; posy; posz;
inradar;
c_id;
drawme;
invisible[1];
fogme;
light_col;
scint;

struct vertex[30]
x,y,z;
xl, yl,zl;
sX[1],sy[1]; sz[1];
END
//-------------

struct edge[30]
v0;
v1;
col;
draw_me[1];
END
//----------

struct face[20]
e[5];
col;
//---------------

END
END
//--------------

struct tmp_vertex[30]
x,y,z;
END
//--------------

struct tmp_edge[30]
v0; v1;
END
//--------------

struct tmp_face[20]
e[5];
END
//--------------



struct fencepost[36]
x,y,z;
end

radar_id[1];
huds_id[1];

gunstate[1];
stopnshoot[1];

snd_rolling;
snd_tilting;
snd_twisting;
snd_beep;
snd_alert;
snd_exp;
snd_shoot;
snd_dot;
snd_click;





counter[1];

line_3d_count;
draw_obj_count;
viewtrans_obj;

LOCAL
c;
renderme;
state;
index;
PRIVATE
i;
 //================================================================================================================
 //================================================================================================================

BEGIN

    set_fps(24,0);
    file0=load_fpg("battlezone.FPG");
    set_mode(scr_w*1000+scr_h);
    scr_cx=scr_w/2;
    scr_cy=scr_h/2;


    snd_rolling=load_wav("ENGINE.WAV",1);
    snd_tilting=load_wav("tilting.wav",1);
    snd_twisting=load_wav("twisting.wav",1);
    snd_beep=load_wav("beep.wav",0);
    snd_alert=load_wav("alert.wav",0);
    snd_exp=load_wav("EXP.WAV",0);
    snd_shoot=load_wav("EXP3.WAV",0);
    snd_dot=load_wav("dot.wav",0);
    snd_click=load_wav("click.wav",0);

    for(i=0; i<2; i+=1)
        cam[i].posX=0;
        cam[i].posY=-10000;
        cam[i].posZ=600;
        cam[i].angle=0;
        cam[i].cx=scr_cx;
        cam[i].w=scr_w;
        cam[i].h=scr_h/2;
        cam[i].depth=scr_w;
        cam[i].fov=atan2(scr_cx,cam[i].depth);
        cam[i].fog=fog;
    END
    cam[0].cy=scr_cy;
    cam[1].cy=scr_cy;
    define_region(1, 0, 0, scr_w, scr_h);
    define_region(2, 0, 0, scr_w, scr_h);





    up[1]=_up;
    dn[1]=_down;
    lf[1]=_left;
    rt[1]=_right;
    ctrl[1]=_r_shift;
    fire[1]=_enter;
    up[0]=_w;
    dn[0]=_s;
    lf[0]=_a;
    rt[0]=_d;
    ctrl[0]=_l_shift;
    fire[0]=_tab;


    gamestate=-1;
    if(gamestate==-2)
      loop
      size=40;
      c=cyan;
      vwrite(100,100,size,c,"compass");
      vwrite(100,140,size,c,"magazine");



       y=0;
      frame;
      delete_drawing();
      end
    end


    if(gamestate==-1)
        intro();
       delete_drawing();

    END
    while(gamestate==-1)
        frame;
    END


    obj_count=0;
    let_me_alone();
    delete_draw(all_drawing);

    define_region(1, 0, 0, scr_w, scr_h/2);
    define_region(2, 0, scr_h/2, scr_w, scr_h/2);
    cam[0].cy=scr_cy/2;
    cam[1].cy=3*scr_cy/2;

    init_objects();
    camera_control();
    physworld();
    make_mounts();
    moon();
    vulcano();

    im_id[0]=messagecentre(tank[0]);
    im_id[1]=messagecentre(tank[1]);
    from c= 0 to 5;
    frame;
    end
    hopin(0); hopin(1);

    delete_drawing();
//============================================================================================

    LOOP
       /*
        write(0,100,500,2,"3dlines: ");
        write_int(0,100,500,0,&line_3d_count);

        write(0,100,510,2,"3dobjects: ");
        write_int(0,100,510,0,&draw_obj_count);


        write(0,100,520,2,"viewtrans: ");
        write_int(0,100,520,0,&viewtrans_obj);

        write(0,100,530,2,"cam_angle ");
        write_int(0,100,530,0,&cam[0].angle);
        write_int(0,100,540,0,&cam[0].posx);
        write_int(0,100,550,0,&cam[0].posz);
      */

        x=50; y=10;
        write(0,x,y,0,"tank"); y+=10;
        write(0,x,y,0,"player");

        x=100; y=10;
        write(0,x,y,0,statetag[tank_id[0].state]); y+=10;
        write(0,x,y,0,statetag[player_id[0].state]); y+=10;
        y=310; x=50;
        write(0,x,y,0,"tank"); y+=10;
        write(0,x,y,0,"player");
        x=100; y=310;
        write(0,x,y,0,statetag[tank_id[1].state]);
        y+=10;
        write(0,x,y,0,statetag[player_id[1].state]);
      /*
         write(0,10,10,0,"KEYS TO TRY");
         write(0,10,20,0,"1: hop out of tanks.  Run around and check out the animation.  Try picking up the fuel or the shell");
         write(0,10,30,0,"2: hop into tanks. Or you can run into your tank to get back in" );
         write(0,10,40,0,"b: switch from running to shooting when on foot");
         write(0,10,50,0,"n: switch from shooting to running when on foot");
         write(0,10,60,0,"space: shoot. (bullets only collide with obstacles at the mo)");
         write(0,10,70,0,"-----------------------------------------------");
         write(0,10,90,0,"The life-cycle is in a mess so if you blow anything up you need to restart.");
      */






        delete_draw(all_drawing);
        draw(2,80,7,0,0,0,scr_w-1,scr_cy-1);
        draw(2,80,7,0,0,scr_cy+1,scr_w-1,scr_h-1);
        FRAME;
    END
END
//============================================================================================
//============================================================================================




process vulcano()
private
burst;
i;
begin
       x=0;
       y=10000;
       z=-100000;

    loop
        if(rand(0,100)==0)
              boulder();
        end

        if(rand(0,400)==0)
            burst=rand(10,30);
        end

        if(burst>0)
          c=rand(0,3);
          for(i=0; i<=c; i+=1)
                burst-=1;
                boulder();
          end
        end
        frame;
    End

end



//------------------------------------------------------------------------------
process boulder()
private
x0; y0; z0;
travel;
x1;y1;z1;
vel;velv;velx;velz;  velh;
col; col0; col1;
begin
    x0=father.x+rand(-800,800); x1=x0;
    y0=father.y; y1=y0;
    z0=father.z; z1=z0;
    angle=rand(60000,90000);
    vel=rand(300,600);
    velv=-get_disty(angle,vel);
    velh=get_distx(angle,vel);
    angle=180000*rand(0,1);
    col1=160+rand(0,8);
    col0=130;
    col=col1;
    while(col>col0)
        if(col<col0)
            col=col0;
        END
        travel+=1;
        IF(Travel mod 4 ==0)
            col-=1;
        end
            x1+=get_distx(angle,velh);
            //x1+=
            y1+=velv;
            //z1+=get_disty(angle,velh);
            if(y1>=0)
                tracer(x0,y0,z0,x1,y1,z1,col,col0,2*rand(2,8));
            END
            if(velh>0)
                velh=99*velh/100;
            END
                velv-=10;
                velv=99*velv/100;


            x0=x1; y0=y1; z0=z1;



        frame;
        if(col<=col0)
            break;
        END
    END

end



//------------------------------------------------------------------------------


process moon()

private
rad=3000:
ang=0;
step_Ang=30000;
tilt=30000;
angz=225000;
angzt;
x0; y0: z0: x1: y1: z1:
col;
struct l[12]
    struct v[1]
     x,y,z;
    end
end
begin
    c=0;
    for(ang=0;  ang<360000; ang+=step_ang)
        c+=1;
        l[c].v[0].z=get_disty(ang,rad);
        l[c].v[0].y=get_distx(ang,rad);

        l[c].v[1].z=get_disty(ang+step_ang,rad);
        l[c].v[1].y=get_distx(ang+step_ang,rad);

    end

    for(c=1;  c<=12; c+=1)
        l[c].v[0].x=100000;
        l[c].v[1].x=100000;

    end




   loop

   angz+=10;
   angz %=360000;
    for(c=1; c<=12; c+=1)
        x0=l[c].v[0].x;
        y0=l[c].v[0].y+12000;
        z0=l[c].v[0].z;
        x1=l[c].v[1].x;
        y1=l[c].v[1].y+12000;
        z1=l[c].v[1].z;




        if(angz<180000 and c<=6  or (angz>=180000 and c>6))
        col=white0+24;
        else
        col=white;
        end
        draw_3dline(x0,y0,z0,x1,y1,z1,1,1,col,white0,0);

        if((angz < 180000 and c<=6) or (angz>=180000 and c>6))
        z0=(z0*cos(angz))/1000;
        z1=(z1*cos(angz))/1000;
        col=white;
        draw_3dline(x0,y0,z0,x1,y1,z1,1,1,col,white0,0);


        end

    end



   frame;
end

end


function hopout(index);
    begin
        tank_id[index].state=onfoot;
        player_id[index].state=hopping;
        body[index].head_id.state=onfoot;
        body[index].arm_r_id.state=onfoot;
        body[index].arm_l_id.state=onfoot;
        body[index].leg_r_id.state=onfoot;
        body[index].leg_l_id.state=onfoot;


        angle=obj[tank[index]].angley;
        x=obj[tank[index]].posx;
        y=player_id[index].height;
        z=obj[tank[index]].posz;
        obj[player[index]].angley=angle;
        position_obj(player[index],x,y+50,z);
        rotate_objxyz(player[index],0,0,0);
        //signal(huds_id[index],s_sleep_tree);
        huds_id[index].state=1;
        hide_tank(index,0,index);
        hide_player(index,0,index);
        hide_player(index,0,1-index);
        score.bullets[index]=score.bullets0;
        if(index==0) scroll.camera=player_id[index]; END

    end
//-------------------------------------------------------------------------------

function hopin(index);
    begin
        if(player_id[index].state==got_fuel)
            score.fuel[index]=score.fuel0;
            s_minifuel[index].part_id[0].state=out;
            hide_minifuel(index,1,index);
            hide_minifuel(index,1,1-index);


        END
        if(player_id[index].state==got_shell)
            score.shells[index]=score.ammo0;
            s_minishell[index].part_id[0].state=out;
            hide_minishell(index,1,index);
            hide_minishell(index,1,1-index);

        END
        player_id[index].state=action;
        tank_id[index].state=action;
        //signal(huds_id[index],s_wakeup_tree);
        huds_id[index].state=0;

        hide_tank(index,1,index);
        hide_player(index,1,index);
        hide_player(index,1,1-index);


    end
//-------------------------------------------------------------------------------
function hide_tank(index,hide,cam)
BEGIN

        obj[tank[index]].invisible[cam]=hide;
        obj[barrel[index]].invisible[cam]=hide;
        obj[turret[index]].invisible[cam]=hide;
        obj[hull[index]].invisible[cam]=hide;
        obj[dish[index]].invisible[cam]=hide;
END

//-------------------------------------------------------------------------------

function hide_player(index,hide,cam)

begin

        obj[player[index]].invisible[cam]=hide;
        obj[body[index].head].invisible[cam]=hide;
        obj[body[index].arm_l].invisible[cam]=hide;
        obj[body[index].arm_r].invisible[cam]=hide;
        obj[body[index].leg_l].invisible[cam]=hide;
        obj[body[index].leg_r].invisible[cam]=hide;

END

//-------------------------------------------------------------------------------

function hide_minishell(index,hide,cam);
begin
        obj[s_minishell[index].part[0]].invisible[cam]=hide;
        obj[s_minishell[index].part[1]].invisible[cam]=hide;


end
//-------------------------------------------------------------------------------

function hide_minifuel(index,hide,cam);
begin
        obj[s_minifuel[index].part[0]].invisible[cam]=hide;
        obj[s_minifuel[index].part[1]].invisible[cam]=hide;


end


//-------------------------------------------------------------------------------


 process delete_drawing()
    BEGIN
        priority=1000000;
        LOOP
            line_3d_count=0;
            draw_obj_count=0;
            viewtrans_obj=0;
            delete_draw(all_drawing);
            FRAME;
        END
    END
//-----------------------------------------------------------------------------------------------

PROCESS intro()
    BEGIN
        menu(400,100);
end

//============================================================================================

process oilpatch(x,y)
private
px[1];
pz[1];

begin
ctype=c_scroll;
graph=106;
    loop
        if(size<1000) size+=10; end
        get_real_point(1, &px[0],&pz[0]);
        from c=2 to 13;
        if(c==13) c=1; END
        get_real_point(c, &px[1],&pz[1]);
        if(c==1) c=13; END
        draw_3dline(px[0],0,pz[0],px[1],0,pz[1],1,1,green0+20-state,green0,1);
        px[0]=px[1];
        pz[0]=pz[1];
        end
        write_int(0,100,100,0,&renderme);
        write_int(0,100,110,0,&state);

        if(renderme==0 and state>0); break; END
        frame;
    end

end


//-----------------------------------------------------------------------------------------------
process blastradius(x,y)
private
px[1];
pz[1];
h=0;
col=white;
col0=white0;
delta_size=40;
begin
ctype=c_scroll;
graph=106;
size=delta_size*10;
    loop
        get_real_point(1, &px[0],&pz[0]);
        from c=2 to 13;
        if(c==13) c=1; END
        get_real_point(c, &px[1],&pz[1]);
        if(c==1) c=13; END
        draw_3dline(px[0],h,pz[0],px[1],h,pz[1],1,1,col,col0,0);
        px[0]=px[1];
        pz[0]=pz[1];
        end
        if(size>0)
            h+=10;
            size-=delta_size;
            col-=8;
            if(col<0) break; end
        else
            break;
        end

        frame;
    end

end


//-----------------------------------------------------------------------------------------------


PROCESS menu(i,j);
    PRIVATE
        snd;
        struct text[10]
            string name;
            index;
        END

        struct rules[16]
            string name;
            index;
        END

        string partial="";

        selected;
        spc=30;
        ticker;
        line=0;
        col; col0;
        rule=0;
        pressing;
        new_rule;
        rule_count=15;
        dy;
        init;
        toy_id[1];
        bbs[1];

    BEGIN

        text[0].name="welcome to div tank arena";
        text[1].name="press space to enter";
        text[2].name="use pgup and pgdn to scroll through instructions";

        ticker=strlen(text[0].name);
        loop
            switch (line)
                case 0:
                    if(ticker>0) ticker-=1;
                    ELSE
                        line=-1;
                        ticker=-10;
                    END
                    partial=text[0].name-ticker;
                    vwrite(10,10,40,green,partial);
                END
                case -1:
                    if(ticker<0)
                        ticker+=1;
                    ELSE
                        ticker=strlen(text[1].name);
                        line=1;
                    END
                END
                case 1:
                    partial=text[1].name-ticker;
                    vwrite(10,25,40,green,partial);
                    if(ticker>0)
                        ticker-=1;
                    ELSE
                        line=-2;
                        ticker=-10;
                    END
                END
                case -2:
                    if(ticker<0)
                        ticker+=1;
                    ELSE
                        ticker=strlen(text[2].name);
                        line=2;
                    END
                END
                case 2:
                    partial=text[2].name-ticker;
                    vwrite(10,40,40,green,partial);
                    if(ticker>0)
                        ticker-=1;
                    ELSE
                        line=-3;
                        line=5;
                        ticker=-10;
                    END
                END

                case -3:
                    if(ticker<0)
                        ticker+=1;
                    ELSE
                        ticker=strlen(text[3].name);
                        line=3;
                    END
                END

                case 3:
                    partial=text[3].name-ticker;
                    vwrite(20,20,50,green,partial);
                    if(ticker>0)
                        ticker-=1;
                    ELSE
                        line=-4;
                        ticker=-10;
                    END
                END


                case -4:
                    if(ticker<0)
                        ticker+=1;
                    ELSE
                        ticker=strlen(text[4].name);
                        line=4;
                    END
                END

                case 4:
                    partial=text[4].name-ticker;
                    vwrite(20,20,40,green,partial);
                    if(ticker>0)
                        ticker-=1;
                    ELSE
                        line=5;
                    END
                END



                case 5:
                    if(key(_space))
                        line=6;
                        col=green+64;
                    END
                    if(key(_pgup))
                    if(pressing<>-1)
                        if(rule>0)
                            rule-=1;
                         else
                         rule=rule_count;
                         END
                            new_rule=1;

                    END
                    END
                    if(key(_pgdn))
                    if(pressing<>1)
                        if(rule<rule_count)
                            rule+=1;
                         else
                         rule=0;
                         END
                            new_rule=1;

                    END
                    END


                    pressing=key(_pgdn)-key(_pgup);
                    if(new_rule==2)
                        ticker=strlen(rules.name);
                        new_rule=0;
                    END
                    partial=rules.name-ticker;
                    if(ticker>0)
                        ticker-=1;
                        snd= sound(snd_click,8,512);
                    END
                        vwrite_int(20,550,green,60,rule);
                        vwrite_int(40,560,green-32,40,rule_count);
                        vwrite(60,550,50,green,partial);
                    //graph=rule+30;
                    x=200; y=0;

                    switch(rule)
                        case 1:
                            rules.name="tank view";

                            x=scr_cx;
                            y=scr_cy;
                            graph=31;
                        vwrite_int(20,550,green,60,rule);

                        end
                        case 2:
                            state=2;
                            rules.name="driving the tank";
                            graph=0;
                            if(init<>rule)
                                toy_id[0]=toytank(0,200,250,0,1,state,0);
                                toy_id[1]=toytank(1,550,450,180000,2,state,0);
                            init=rule;
                            end
                            from c=0 to 1;
                                if(c==0)
                                    x=20;
                                    y=100;
                                    col0=green;
                                    text[4] = "forward      w";
                                    text[5] = "reverse      s";
                                    text[6] = "turn left    a";
                                    text[7] = "turn right   d";

                                else
                                   x=640;
                                   y=500;
                                   col0=cyan;
                                    text[4] = "W   forward";
                                    text[5] = "S   reverse";
                                    text[6] = "A   turn left";
                                    text[7] = "D   turn right";

                                end
                                dy=20;
                                if(key(up[c])) col=col0; else col=col0-32; end
                                vwrite(x,y,60,col,text[4]);
                                if(key(dn[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[5]);
                                if(key(lf[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[6]);
                                if(key(rt[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[7]);
                            end

                         end
                        case 3:
                             state=3;
                             rules.name="aiming the cannon";
                            graph=0;

                            if(init<>rule)
                                toy_id[0]=toyturret(0,200,250,0);
                                toy_id[1]=toyturret(1,550,450,180000);
                                init=rule;
                            end

                            from c=0 to 1;
                                if(c==0)
                                    x=20;
                                    y=100;
                                    col0=green;
                                    text[4] = "aim up     shift w";
                                    text[5] = "aim down   shift s";
                                    text[6] = "aim left   shift a";
                                    text[7] = "aim right  shift d";

                                else
                                   x=600;
                                   y=500;
                                   col0=cyan;
                                    text[4] = "shift W   aim up";
                                    text[5] = "shift S   aim down";
                                    text[6] = "shift A   aim left";
                                    text[7] = "shift D   aim right";

                                end
                                dy=20;
                                if(key(up[c]) and key(ctrl[c])) col=col0; else col=col0-32; end
                                vwrite(x,y,60,col,text[4]);
                                if(key(dn[c]) and key(ctrl[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[5]);
                                if(key(lf[c]) and key(ctrl[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[6]);
                                if(key(rt[c]) and key(ctrl[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[7]);
                            end


                        end
                        case 4:
                            rules.name="firing the cannon";
                            state=4;
                            graph=0;

                            if(init<>rule)
                                toy_id[0]=toyshooter(0,150,300);
                                toy_id[1]=toyshooter(1,550,300);
                                init=rule;
                            end
                            text[4] = "shoot each other!";
                            from c=0 to 1;
                                if(c==0)
                                    x=20;
                                    y=100;
                                    col0=green;
                                    text[5] = "fire  tab";
                                    draw(2,col0-32,15,0,x+50,y-4,x+82,y+16);

                                else
                                   x=600;
                                   y=500;
                                   col0=cyan;
                                    text[5] = "enter  fire";
                                    draw(2,col0-32,15,0,x-4,y-4,x+56,y+16);
                                end
                                vwrite(260,140,100,245+rand(0,5),text[4]);

                                if(key(fire[c])) col=col0; else col=col0-32; end
                                    vwrite(x,y,60,col,text[5]);
                                end

                        end



                        case 5:
                            rules.name="collect fuel and shells";
                            state=5;
                            graph=0;

                            if(init<>rule)
                                toy_id[0]=toymover(0,150,300);
                                toypwr(7,400,300);
                                toypwr(8,650,300);

                                init=rule;
                            end

                        end
                        case 6:
                             rules.name="eject! eject! eject!";
                            state=6;
                            graph=0;

                            if(init<>rule)
                                toy_id[0]=toyhopper(0,200,300);
                                toy_id[1]=toyhopper(1,600,300);

                                init=rule;
                            end

                            from c=0 to 1;
                                if(c==0)
                                    x=20;
                                    y=100;
                                    col0=green;
                                    text[4] = "eject   a d";

                                else
                                   x=600;
                                   y=500;
                                   col0=cyan;
                                    text[4] = "A D   eject";

                                end
                                dy=20;
                                if(key(lf[c]) and key(rt[c])) col=col0; else col=col0-32; end
                                vwrite(x,y,60,col,text[4]);
                            end



                        end
                        case 7:
                            rules.name="view from the outside";
                            state=7;
                            graph=0;
                            x=scr_cx;
                            y=scr_cy;

                                if(init<>rule)
                                toy_id[0]=footview(0,200,200,32);
                                toy_id[1]=footview(1,600,400,33);

                                init=rule;
                            end


                            from c=0 to 1;
                                if(c==0)
                                    x=20;
                                    y=100;
                                    col0=green;
                                    text[4] = "switch mode   shift";

                                else
                                   x=600;
                                   y=500;
                                   col0=cyan;
                                    text[4] = "shift switch mode";

                                end
                                dy=20;
                                if(key(ctrl[c]))
                                    col=col0;

                                else
                                    col=col0-32;
                                end
                                vwrite(x,y,60,col,text[4]);
                            end




                        end


                        case 8:
                            state=8;
                            rules.name="running around";
                            graph=0;
                            if(init<>rule)
                                toy_id[0]=toytank(0,100,250,0,114,state,1);
                                toy_id[1]=toytank(1,700,450,180000,115,state,1);
                            init=rule;
                            end
                            from c=0 to 1;
                                if(c==0)
                                    x=20;
                                    y=100;
                                    col0=green;
                                    text[4] = "forward      w";
                                    text[5] = "backwards    s";
                                    text[6] = "turn left    a";
                                    text[7] = "turn right   d";

                                else
                                   x=640;
                                   y=500;
                                   col0=cyan;
                                    text[4] = "W    forward";
                                    text[5] = "S    backwards";
                                    text[6] = "A    turn left";
                                    text[7] = "D    turn right";

                                end
                                dy=20;
                                if(key(up[c])) col=col0; else col=col0-32; end
                                vwrite(x,y,60,col,text[4]);
                                if(key(dn[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[5]);
                                if(key(lf[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[6]);
                                if(key(rt[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[7]);
                            end



                        end
                        case 9:
                            rules.name="aiming and shooting";
                            state=9;
                            graph=36;
                            if(init<>rule)
                               // toy_id[0]=;
                               // toy_id[1]=;
                               toytargets(400,300,state);
                            init=rule;
                            end

                            from c=0 to 1;
                                if(c==0)
                                    x=20;
                                    y=80;
                                    col0=green;
                                    text[4] = "aim up     w";
                                    text[5] = "aim down   s";
                                    text[6] = "aim left   a";
                                    text[7] = "aim right  d";
                                    if(bbs[c]>0)
                                        text[8] = "enter  fire";
                                    else
                                        text[8] = "enter  reload";
                                    end

                                else
                                   x=640;
                                   y=500;
                                   col0=cyan;
                                    text[4] = "W    aim up";
                                    text[5] = "S    aim down";
                                    text[6] = "A    aim left";
                                    text[7] = "D    aim right";
                                    if(bbs[c]>0)
                                        text[8] = "tab  fire";
                                    else
                                        text[8] = "tab  reload";
                                    end
                                end
                                dy=20;
                                if(key(up[c])) col=col0; else col=col0-32; end
                                vwrite(x,y,60,col,text[4]);
                                if(key(dn[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[5]);
                                if(key(lf[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[6]);
                                if(key(rt[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[7]);
                                if(key(fire[c])) col=col0; else col=col0-32; end
                                y+=dy; vwrite(x,y,60,col,text[8]);

                            end
                            x=400;
                            y=300;



                        end
                        case 10:
                             rules.name="collect supplies on foot" ;
                        end
                        case 11:
                             rules.name="try using the shell as a kamikazi jetpack";
                        end
                        case 12:
                             rules.name="or maybe make a highly inflammable puddle";
                        end
                        case 13:
                             rules.name="tanks burn";
                        end
                        case 14:
                             rules.name="as do people";
                        end
                        case 15:
                             rules.name="you lose it out here you're in a world of hurt";
                        end
                        default:
                        end
                    end
                    if(new_rule==1) new_rule=2; end

                END

                case 6:
                    if(col>64)
                        col-=12;
                    ELSE
                        signal(id,s_kill_tree);
                        gamestate=0;
                        break;
                    END
                END
                default:
                END

            END

               for(c=0; c<3; c+=1);
               if(abs(line)>c)
                  vwrite(10,10+15*c,40,green0+32,text[c].name);
               end
               end

                state=rule;
            frame;
        END
    end



process footview(n,x,y,graph0)
private
pressing;
col;
toy_id[1];
begin
graph=graph0;
if(n==0)
    col=green;
else
    col=cyan;
end

    loop
        if(key(ctrl[n]))

            if(pressing==0)
                if(graph==graph0)
                    graph+=2;
                else
                     graph=graph0;
                end
            end
            pressing=1;
        else
            pressing=0;
        end

        if(graph==32)
           vwrite(x,y,60,col,"running mode");
        else
           vwrite(x,y,60,col,"shooting mode");
        end

        if(father.state<>7)
            break;
        end

        frame;
    end
end



process toytargets(x,y,state)
private
bot;
top;
vtop;
toy_id[1];
x0; y0; x1; y1;
hit;
struct laser[1];
x,y,
dx,dy,
col;
end  =400,300,0,0,255,400,300,0,0,254;
col[1];
begin
    bot=y+70;
    top=y-50;
    vtop=y-120;
    from c=0 to 4;
        toytarget(c,120,bot,0,28);
        toytarget(c,680,bot,1,29);
    end
    toy_id[0]=toyman(0,x-100,500);
    toy_id[1]=toyman(1,x+100,500);
    col[0]=green;
    col[1]=cyan;

    from c=0 to 9;
        toybottle(x-220+48*c+rand(-4,4),vtop,37);
    end

            toyrocketman(0,x,top);
            toyrocketman(1,x,top);

   loop

        from c=0 to 1;
        if(key(up[c]))
            laser[c].dy-=4;

        end
        if(key(dn[c]))
            laser[c].dy+=4;
        end
        if(key(rt[c]))
            laser[c].dx+=4;
        end
        if(key(lf[c]))
            laser[c].dx-=4;
        end


        if(laser[c].dy<-10)
           laser[c].dy=-10;
        else
            if(laser[c].dy<-10)
                laser[c].dy=-10;
            end
        end
        if(laser[c].dx<-10)
           laser[c].dx=-10;
        else
            if(laser[c].dx<-10)
                laser[c].dx=-10;
            end
        end


         laser[c].dx=laser[c].dx/2;
         laser[c].dy=laser[c].dy/2;

         laser[c].dx=laser[c].dx+=rand(-1,1);
         laser[c].dy=laser[c].dy+=rand(-1,1);

         laser[c].x+=laser[c].dx;
         laser[c].y+=laser[c].dy;

         if(abs(laser[c].x-400)>300)
            laser[c].x-=laser[c].dx;
         END

         IF(laser[c].y<128)
            laser[c].y-=laser[c].dy;
         end
        //if(key(fire[c])

       // end
        hit=toylaserdot(laser[c].x,laser[c].y);
        if(hit or laser[c].y>200)
        draw(rand(2,5),laser[c].col,15,0,laser[c].x-rand(0,2),laser[c].y-rand(0,2),laser[c].x+rand(0,2),laser[c].y+rand(0,2));
        end
        x1=toy_id[c].x+50;
        y1=toy_id[c].y+23;
        x0=x1+(laser[c].x-toy_id[c].x)/20;
        y0=y1+(laser[c].y-toy_id[c].y)/20;

        draw(2,col[c],15,0,x0-9,y0-9,x0+9,y0+9);
        draw(1,col[c],15,0,x0-9,y0-9,x1-9,y1-9);
        draw(1,col[c],15,0,x0+9,y0-9,x1+9,y1-9);
        draw(1,col[c],15,0,x0+9,y0+9,x1+9,y1+9);
        draw(1,col[c],15,0,x0-9,y0+9,x1-9,y1+9);

        end

        if(father.state<>state)
            signal(id,s_kill_tree);
        end
        frame;
   end


end



process toylaserdot(x,y)
 begin
 graph=19;
 if(collision(type toybottle));
 return(1);
 else
 return(0);
 end
 end




process toytarget(c,x0,y0,n,graph0)
private
dir;
dist=0;
vel=1;
begin
    x=x0;
    y=y0;
    dist=48*c;
    while(dist>0)
        dist+=vel;
        if(dist>=240)
            dist=0;

        end
        frame;
    end
    dir=1-n*2;
    graph=graph0;
    z=father.father.z+1;
    loop
        if(dist<240)
            x+=dir*vel;
            dist+=vel;
        else
            angle-=3000*dir;
            if( abs(angle)>90000)
                angle=0;
                x=x0;
                dist=0;
            end
        end
        frame;
    end
end



process toyman(n,x,y)
private
dir;
begin
dir=1-(n*2);

    graph=n+118;
    toyarm(n,n+122,x+50,y+24);
    loop
        frame;
    end

end


process toyarm(n,graph0,x,y);
private
col;
x0; y0;
begin
col=green;
graph=graph0;
loop
    frame;
end

end




process toybottle(x,y,graph0)
private
begin
    graph=graph0;
    loop
        frame;
    end
end


process toytank(n,x,y,angle,graph0,state,walk);
private
walking=-1;
cyc=1;
begin
    graph=graph0;
    resolution=1000;
    x*=resolution;
    y*=resolution;
    loop

        if(key(up[n]))
           advance(5000);
           if(walk) walking+=1; end
        end
        if(key(dn[n]))
           advance(-5000);
           if(walk) walking+=1; end
        end
        if(key(lf[n]))
           angle+=3000;
        end
        if(key(rt[n]))
           angle-=3000;
        end


        if(walk)
            if(not key(up[n]) and not key(dn[n]))
                walking=-1;
                graph=graph0;
            else
                if(walking mod 4==0)
                    cyc+=(graph0-graph);
                    graph+=cyc*2;
                end
            end
        end
        if(father.state<>state)
    break;
    end
    frame:
    end
end



process toyrocketman(c,x,y)
private
dir;
amp=30;
y0;
theta;
dist;
vel;
col;
top;
segs;
x0;
flying=0;
count;
i;
begin
    top=y-16;
    vel=4;
    dist=0;
    y0=y+30;
    theta=rand(0,360000);
    z=father.z+1;
    if(c==0)
        col=green0+24;
    else
        col=cyan0+24;
    end

    dir=1-2*c:
    graph=124+c;
    x0=x-260*dir;
    x=x0;
    loop
        if(flying==0 and rand(0,800)==1)
            flying=1;
        end
        if(flying==1)
            theta+=3000;
            y=y0+get_distx(theta,amp);
            x+=dir*vel:
            dist+=vel;
            for(segs=top; segs<=y; segs+=10);
                toystalk(x+6*dir,segs,graph+2);
            end
            count=rand(0,5);
            for(i=0; i<=count; i+=1)
                toyexhaust(x,y,dir);
            end
            if(dist>=520)
                flying=0;
                x=x0;
                theta=rand(0,360000);
                dist=0;
            end
         end
        frame;
    end
end


process toyexhaust(x0,y0,dir)
private
col; decay; vel;
vy;  vz;
x1; y1;
begin
x=x0;
y=y0;
x1=x;
y1=y;
col=rand(165,175);
vel=-rand(1,6)*dir;
decay=rand(2,10);
vy=rand(-1,1);
vz=2*rand(0,1)-1;
while(col>128)
x+=vel;
y+=vy;
z+=vz;
col-=decay;
if(col>128)
    if(abs(400-x0)<260 and y>250)
        if(abs(400-x)<232)
            draw(1,col,15,0,x1,y1,x,y);
        else
            if(z>10)
                draw(1,col,15,0,x1,y1,x,y);
            else
                signal(id,s_kill);
            end
        end
    end

end
x1=x;
y1=y;
frame;
end
end





process toystalk(x,y,graph)
begin
z=father.z+1;
frame;
end


process toyturret(n,x,y,angle);
begin
    resolution=1000;
    x*=resolution;
    y*=resolution;
    graph=n+40;
    toyhull(n,x,y,graph+2,angle,resolution);
    toybarrel(n,x,y,graph+4,resolution);
    loop
        if(key(ctrl[n]))
            if(key(lf[n]))
                angle+=3000;
            end
            if(key(rt[n]))
                angle-=3000;
            end
        end

        if(father.state<>3)
    signal(id,s_kill_tree);
    end
    frame:
    end
end


process toyhull(n,x,y,graph,angle,resolution)
begin
z=father.z+1;
loop
frame;
end
end


process toybarrel(n,x,y,graph,resolution)
begin
        if(n==0) y+=200000; else y-=200000; END
        toytop(n,x+50000-100000*n,y,graph+2,resolution);
loop
        if(key(ctrl[n]))
            if(key(up[n]))
                c+=(3000);
                if(c>30000)
                    c=30000;
                end
            end
            if(key(dn[n]))
                c-=(3000);
                if(c<0)
                    c=0;
                end

            end
        end
            if(n==0)
                angle=c;
            else
                angle=-c;
            end

frame;
end
end

process toytop(n,x,y,graph,resolution)
begin
loop
frame;
end
end



process toyshooter(n,x,y)
private
col0;
hit;
spares=4;
i;
begin
if(n==0)
    col0=green;
else
    col0=cyan;
end
graph=n+48;
loop
    for(i=1;i<=spares; i+=1)
       toyspare(x-20*((n*2)-1)+30*i*((n*2)-1),y+80,n+5);
    end

    if(graph>=125)
        if(spares>0)
            spares-=1;
            graph=n+48;
            size=100;
        else
           break;
        end
    end
    if(father.state<>4)
        signal(id,s_kill_tree);
    end
    if(graph==n+48)
        if(key(fire[n]) and state==0)
            if(c==0)
                toyshell(n,x,y);
                state=50;
                c=1;
            end
        else
            c=0;
        end
        if(state>0)
            vwrite(x-40,y-50,40,col0-32+4*(state mod 4),"reloading!");
            state-=1;
        end
    else
        state=0;
    end
    if(father.state<>4)
        signal(id,s_kill_tree);
    end
    hit=collision(type toyshell);

    if(hit)
        signal(hit,s_kill);
        size=300;
        graph=111;
        hit=0;
    end
    if( size==300)
        graph=graph+1;
    end

frame;
end
end




process toyhopper(n,x,y)
begin
graph=n+48;
loop

    if(key(lf[n]) and key(rt[n]) and c==0)
       father.c=1;
        mrhopper(n,x,y);
    end


    if(father.state<>6)
        signal(id,s_kill_tree);
    end
frame;
end
end

process mrhopper(n,x,y)
private
vy=-10;
vx;

begin
    vx=(1-(n*2))*2;
  father.c=2;
  size=50;
  loop
  if(size<100) size+=5; end
  if(abs(vy)<7)
    graph=n+108;
  else
    graph=n+110;

  end
  if(y<340)
    y+=vy;
    vy+=1;
    x+=vx;
  end
  frame;
  end
end



process toymover(n,x,y)
private
col0; col1; col2;
hit;
i;
vel=5;
f=200;
a=1;
fmax=1000;
amax=10;
reload;
refuel;
begin
    i=-36;
    col0=green;
    col1=col0;
    col2=col0;
graph=n+48;
loop
    i+=1;

          if(i==-12)
          toyshell(n,x,y);
          a-=1;
          end
          if(i>24)
          x+=vel;
          f-=1;
          end


            c=collision(type toypwr);
            if(c)
                if(c.graph==7)
                reload=1;
                else
                refuel=1;;
                end
                signal(c,s_kill);
            end

          if(a>0)
            vwrite(x-100,y-60,60,col0-32,"ammo");
          else
            vwrite(x-100,y-60,60,150+rand(0,5),"no ammo");

          end
          vwrite(x-100,y-80,60,col0-32,"fuel");

          if(a>0)
            vwrite_int(x-20,y-60,col1,60,a);
          end
          vwrite_int(x-20,y-80,col2,60,f);


          if(reload==1)
            i=0;
            if(a<amax)
                a+=1;
                col1=white;
            else
            reload=0;
            col1=col0;
            end
          end

          if(refuel==1)
            i=0;
            if(f<fmax)
                f+=100;
                col2=white;
                if(f>1000) f=1000; end
            else
            refuel=0;
            col2=col0;
            end
          end




    if(father.state<>5)
        signal(id,s_kill_tree);
    end
frame;
end
end

process toypwr(graph,x,y)

begin
  loop
    if(father.state<>5)
        signal(id,s_kill);
    end

frame;
end
end

process toyspare(x,y,graph)

begin
    frame;
end

process toyshell(n,x,y)

begin
graph=n+38;
z=father.z+1;
     while(c==0)
        if(n==0)
            advance(10);
        else
            advance(-10);
        end

     frame;
     end

end



//============================================================================================

PROCESS vwrite(x,y,size,col,string txt);
    PRIVATE
        i; j; k;  ch;

    BEGIN
        i=x; j=y;
        for(c=0; c<strlen(txt); c+=1)
            k=char(txt[c]);
            switch(k)
                case char(" "): ch=_#;  END
                case char("a"): ch=a#;  END
                case char("b"): ch=b#;  END
                case char("c"): ch=c#;  END
                case char("d"): ch=d#;  END
                case char("e"): ch=e#;  END
                case char("f"): ch=f#;  END
                case char("g"): ch=g#;  END
                case char("h"): ch=h#;  END
                case char("i"): ch=i#;  END
                case char("j"): ch=j#;  END
                case char("k"): ch=k#;  END
                case char("l"): ch=l#;  END
                case char("m"): ch=m#;  END
                case char("n"): ch=n#;  END
                case char("o"): ch=o#;  END
                case char("p"): ch=p#;  END
                case char("q"): ch=q#;  END
                case char("r"): ch=r#;  END
                case char("s"): ch=s#;  END
                case char("t"): ch=t#;  END
                case char("u"): ch=u#;  END
                case char("v"): ch=v#;  END
                case char("w"): ch=w#;  END
                case char("x"): ch=x#;  END
                case char("y"): ch=y#;  END
                case char("z"): ch=z#;  END
                case char("0"): ch=n0#;  END
                case char("1"): ch=n1#;  END
                case char("2"): ch=n2#;  END
                case char("3"): ch=n3#;  END
                case char("4"): ch=n4#;  END
                case char("5"): ch=n5#;  END
                case char("6"): ch=n6#;  END
                case char("7"): ch=n7#;  END
                case char("8"): ch=n8#;  END
                case char("9"): ch=n9#;  END
                case char("!"): ch=excl#;  END
                case char("'"): ch=apos#; end
                case char("W"): ch=up#;  END
                case char("S"): ch=dn#;  END
                case char("A"): ch=lf#;  END
                case char("D"): ch=rt#;  END

                default: END
            END
            vwrite_symbol(ch,i,j,size,col);
            i+=15*Size/100;
        END
    END
//============================================================================================

PROCESS vwrite_int(x,y,col,size,n)
    PRIVATE
        i;
    BEGIN
        c=1;
        repeat
            i=(n mod (10*c))/c;
            i+=30;
            vwrite_symbol(i,x,y,size,col);
            c*=10;
            x-=15*size/100;
        until (n/c==0)
END

//============================================================================================
PROCESS vwrite_symbol(n,x,y,size,col)
    PRIVATE
        graph0=50;
        last_point=250;
        join_next=254;
        join_start_last=252;
        join_start_next=253;
        p;
        x0; y0;  x1; y1;
        cnt;
        g;
    BEGIN
        if(n<>0)
            g=graph0+n;
            p=0;
            priority=-1000;
            while(c<>last_point)
                p+=1;
                get_point(0,g,p,&x0,&y0);
                get_point(0,g,p+1,&x1,&y1);
                c=map_get_pixel(0,g,x0,y0);
                if(c==join_next)
                    x0=x0*size/100;
                    x1=x1*size/100;
                    y0=y0*size/100;
                    y1=y1*size/100;
                    x0+=x; y0+=y; x1+=x; y1+=y;
                    draw(1,col,15,0,x0,y0,x1,y1);
                END
                if(c==join_start_last or c==join_start_next)
                    get_point(0,g,1,&x1,&y1);
                    x0=x0*size/100;
                    x1=x1*size/100;
                    y0=y0*size/100;
                    y1=y1*size/100;
                    x1+=x; y1+=y; x0+=x; y0+=y;
                    draw(1,col,15,0,x0,y0,x1,y1);
                    if(c==join_start_last)
                        c=last_point;
                    END
                END
            END
            FRAME;
        END
    END

//============================================================================================
Process physworld()
    PRIVATE
        s_back;
    BEGIN
        s_back=new_map(256,256,0,0,64);
        START_Scroll(0,0,s_back,0,0,15);
        z=draw_z+1;
        scroll.z=z+1;
        graph=new_map(scr_w,scr_h,0,0,64);
        loop
            frame;
        end
    END
//-----------------------------------------------------------------

PROCESS perimeter()
    PRIVATE
        w=10000;
        x0; z0; x1; z1;  i;  d;
        lx0; lz0; lx1; lz1;
        struct pst
            x,y,z,col;
        END
        id2;
        gate;
    BEGIN
        x0=-w;
        z0=-w;
        x1=w;
        z1=w;


        for(c=1; c<=8; c+=1)
            pst.x=get_disty((c+1)*15000-90000,w);
            pst.y=0;
            pst.z=get_distx((c+1)*15000-90000,w);
            pst.col=green+1;
            if(c==5)
                gate=obj_count;
                //id2=init_plane(1300,500,pst.x,pst.y,pst.z,(c+1)*15000,green);
                id2=init_box(100,100,100,pst.x,pst.y,pst.z,(c+1)*15000,green0);
                rotate_objxyz(obj_count-1,0,90000-(c+1)*15000,0);
            ELSE
                init_plane(1300,600,pst.x,pst.y,pst.z,(c+1)*15000,green);
                rotate_objxyz(obj_count-1,0,90000-(c+1)*15000,0);
            END
        END
        return( id2);
    END

//-----------------------------------------------------------------
process messagecentre(index)
    PRIVATE
        tcounter;
        string targethit="target destroyed";
        STRING ALERT= "enemy alert";
        string  partial="";
        string message ="";
        col;
        snd;
    BEGIN
        LOOP
            x=cam[index].cx;
            y=cam[index].cy;
            if(state==respawn)
                state=ready;
                c=0;
            END
            switch (state)
                case ready:
                    if(c==0)
                        sound(snd_alert,32,256);
                    END
                    c+=1;
                    if(c mod 3==0)
                        vwrite(x-90,y-20,120,red,alert);
                        state=ready;

                    END
                    if(c==30)
                        state=1;
                    END
                END
                case boom:
                    c=-20;
                    state=exploding;
                    message=targethit;
                    score.tanks[1-index]-=1;

                END
                case exploding:
                    c+=1;
                    if(c>=0)
                            col=cyan;
                        if(c<strlen(message))
                            snd= sound(snd_click,256,256);
                            partial=message-(strlen(message)-c);
                            vwrite(x-115,y-10,100,col,partial);
                        ELSE
                            vwrite(x-115,y-10,100,col,message);
                         END
                         if(c>80)
                             state=1;
                         END
                     END
                 END
                 default:
                 END
            END
            FRAME;
        END
    END


//-------------------------------------------------------------------------------------------
PROCESS huds(index,x,y);
    PRIVATE
        h1; w1; col0=100;  col;   draw_col;
        h2;  w2;
        h3;  K; l; j; m;    h;
        sx; sy;
        compass_id;
        snd;

    BEGIN
        h1=(scr_cy/2)*8/12;
        h2=scr_cy/2;
        h3=scr_cy/2*4/12;
        w1=80;
        w2=60;
        h=10;
        while(not turret[index])
            frame;
        END
        compass_id=compass(index,x,y+h1-20,&obj[turret[index]].angley,1);
        radar_id[index]=radar(index,scr_w-scr_cy/4,scr_cy*(1+index)-scr_cy/4,scr_cy/4);
        LOOP

            switch (state)
                case 0:
                    col=col0:
                    draw(1,80,15,0,x,y+h1-20,x,y+h2);
                    draw(1,80,15,0,x,y-h1,x,y-h2);
                    draw(1,80,15,0,x-w1,y-h1,x+w1,y-h1);
                    draw(1,80,15,0,x-w1,y+h1,x+w1,y+h1);

                    draw(1,80,15,0,x-w1,y+h1,x-w1,y+h3);
                    draw(1,80,15,0,x-w1,y-h1,x-w1,y-h3);

                    draw(1,80,15,0,x+w1,y+h1,x+w1,y+h3);
                    draw(1,80,15,0,x+w1,y-h1,x+w1,y-h3);
                    for(c=0; c<9; c+=1)
                        draw_col=col-10;
                        draw(1,80,15,0,x-w2-5+c,y-50+get_disty(c*5000,64),x-w2-10,y-50+get_disty(c*5000,64));
                    END
                    sx=x+w1-20;
                    sy=y+h1-10;
                    hud_fuel(sx,sy,score.fuel[index],-10000,index);
                    sx=x-40;
                    sy=y-h1+30;
                    hud_gun(sx,sy,index);
                    col=col0;
                    //vwrite_int(x-w1+20,y+h1-30,col,80,score.tanks[index]);
                    if(shaft_id[index])
                        draw_col=col0+20;
                        draw(1,draw_col,15,0,x-w2+2,y+-50+get_disty(shaft_id[index].angle,240),x-w2-10,y-50+get_disty(shaft_id[index].angle,240));
                        vwrite_int(x-w2+5,y-60+get_disty(shaft_id[index].angle,240),draw_col,40,shaft_id[index].angle/10);
                    END
                END
                case 2:
                    if(score.bullets[index]>0)
                        for(c=1; c<=score.bullets[index]; c+=1);
                            hud_bullet(x+scr_cx-40,y+scr_cy/2-20,12,z-1000,c,index);
                        end
                    else
                        if(c>5) c=0; end
                        c+=1;
                        vwrite(scr_cx-20,y+scr_cy/2-120,80,245+c,"reload");

                    end
                end
                default:
                end
            end
        FRAME;
        END
    END
//_______________________________________________________________________________
PROCESS hud_gun(x,y,index)
    private
        col;
        string destruct= "self destruct";
        string bollox="bollox!";
        string partial="";
        snd;
        TICKER:
    BEGIN

        c=0;
        if(gunstate[index]==0)
                col=199+timer[index]/10 mod 4;
                if(score.shells[index]>0)
                    timer[7+index]=0;

                ELSE
                    col=192+timer[index]/10 mod 4;
                    vwrite(cam[index].cx-70,cam[index].cy-80,120,red,"no ammo!");
                    if(score.fuel[index]>40)
                        timer[7+index]=0;
                    ELSE
                        switch (timer[7+index])
                            case 0..200:
                                ticker=strlen(bollox)-(timer[7+index])/5:
                                if(ticker>0)
                                    if(timer[7+index] mod 2==0)
                                        snd= sound(snd_click,256,256);
                                    END
                                    partial=bollox-ticker;
                                    vwrite(x,y+70,60,col,partial);
                                ELSE
                                    vwrite(x,y+70,60,col,"bollox!");
                                END
                            END
                            case 201..400:
                                ticker=strlen(destruct)-(timer[7+index]-200)/5:
                                if(ticker>0)
                                    if(timer[7+index] mod 2==0)
                                        snd= sound(snd_click,256,256);
                                    END
                                    partial=destruct-ticker;
                                    vwrite(x-20,y+70,60,col,partial);
                                ELSE
                                    vwrite(x-20,y+70,60,col,"self destruct");
                                    counter[index]=0;
                                END
                            END
                            case 401..6400:
                                vwrite_int(x+10,y+60,col,200,(6400-timer[7+index]) / 100);
                                vwrite_int(x+60,y+60,col,100,((6400-timer[7+index]) )mod 100 );
                                if(timer[7+index] / 100> counter[index])
                                    snd= sound(snd_click,256,180+timer[7+index]/10);
                                    counter[index]=timer[7+index] / 100;
                                END
                            END
                            default:
                                tank_id[index].state=boom;
                                score.shells[1-index]=score.ammo0;
                                score.fuel[1-index]=score.fuel0;

                            END
                        END
                    END
                END
        else
            timer[7+index]=0;
        END

        x+=80;
        y-=10;
        for( c=score.shells[index]; c>=1; c-=1)
            x-=8;
            hud_shell(x,y,13,z-1000,c,index);

        END
        FRAME;
    END

//_______________________________________________________________________________
PROCESS hud_fuel(x,y,amount,z,index)
    private
        col ;
    BEGIN
        col=250-amount*10/score.fuel0;
        if(amount>=50)
            vwrite_int(x+10,y-10-30*amount/score.fuel0,col,36,amount/30);
            for(c=0; c<10*amount/score.fuel0; c+=1)
                draw(1,250-c,15,0,x+4,y-c*3,x+10,y-c*3);
            END
        else
            vwrite(cam[index].cx-70,cam[index].cy+60,120,red+rand(0,4),"no fuel!");
        END
        FRAME;
    END

//_______________________________________________________________________________
PROCESS hud_Shell(x,y,graph,z,c,index)
    private
    i;
    BEGIN
        if(c==score.shells[index])
            if(timer[index]<100)
                c=timer[index]/3 mod 35;
                for(i=x; i<=x+c; i+=8)
                    ghost(i,y,z,graph,4);
                END
                x+=c;
            else
                x+=30;
                graph=14;
                y+=4;
            END
        END
        FRAME;
    END

//_______________________________________________________________________________

PROCESS hud_bullet(x,y,graph,z,n,index)
    private
    i;
    BEGIN
                y-=n*10;
        FRAME;
    END



//_______________________________________________________________________________
PROCESS ghost(x,y,z,graph,flags)
    BEGIN
        FRAME;
    END
 //-----------------------------------------------------------------------------------------------------




PROCESS compass(index,x0,y0,angley,points)
    PRIVATE
        h1; w1; col0=127;  col;
        h2;  w2;
        h3;  K; l; j; m;
    BEGIN
        h1=(scr_cy/2)*8/12;
        h2=scr_cy/2;
        h3=scr_cy/2*4/12;
        w1=60;
        w2=30;
        LOOP
            switch(father.state)
                case 0;
                x=x0;
                y=y0;
                    col=col0;
                    if(turret[index])
                        for(c=1; c<=4; c+=1)
                            j=get_disty(*angley-45000-90000*c,w2);
                            l=get_distx((*angley-45000-90000*c)/2,5);
                            draw(1,col,15,0,x-j,y+l,x-j,y-l);
                        END
                        j=get_disty(*angley-5000,w2);
                        l=get_distx(*angley/2,6);
                        k=get_disty(*angley+5000,w2);
                        if(*angley<=90000 or *angley>=270000)
                            col=red;
                        else
                            col=0;
                        END
                        if(*angley>180000)
                            l=-l;
                        END
                        draw(1,col,15,0,x-j,y+l,x-j,y-l);
                        draw(1,col,15,0,x-k,y+l,x-k,y-l);
                        draw(1,col,15,0,x-k,y+l,x-j,y-l);

                        j=get_disty(*angley-5000-180000,w2);
                        l=get_distx((*angley-180000)/2,6);
                        k=get_disty(*angley+5000-180000,w2);
                        if(*angley>=90000 and *angley<=270000)
                            col=col0;
                        else
                            col=0;
                        END
                        draw(1,col,15,0,x-j,y-l,x-k,y-l);
                        draw(1,col,15,0,x-j,y+l,x-k,y+l);
                        draw(1,col,15,0,x-k,y+l,x-j,y-l);
                        j=get_disty(*angley-5000+90000,w2);
                        l=get_distx((*angley+90000)/2,6);
                        k=get_disty(*angley+5000+90000,w2);
                        if(*angley>=0 and *angley>=180000)
                            col=col0;
                        else
                            col=0;
                        END
                        draw(1,col,15,0,x-j,y+l,x-j,y-l);
                        draw(1,col,15,0,x-j,y+l,x-k,y+l);
                        draw(1,col,15,0,x-j,y-l,x-k,y-l);
                        draw(1,col,15,0,x-j,y-1,x-k,y-1);
                        j=get_disty(*angley-5000+270000,w2);
                        k=get_disty(*angley+5000+270000,w2);
                        l=get_distx((*angley+270000)/2,6);
                        m=get_disty(*angley+270000,w2);
                        if(*angley>=0 and *angley<=180000)
                            col=col0;
                        else
                            col=0;
                        END
                        draw(1,col,15,0,x-j,y+l,x-j,y-l);
                        draw(1,col,15,0,x-k,y+l,x-k,y-l);
                        draw(1,col,15,0,x-j,y-l,x-m,y);
                        draw(1,col,15,0,x-k,y-l,x-m,y);
                    END
                end
                case 1:

                end
                default:
                end
            end
        FRAME;
    END
 END
////_________________________________________________________________________________
PROCESS init_objects()
    private
        n;  R;  ang; mini;
    BEGIN

  //TANKS MUSTCOME FIRST
        TAnk[0]=obj_count;
        init_tank(0,0,1000,0,green);
        TANK[1]=obj_Count;
        init_tank(0,0,-1000,-180000,green);
        add_tank_parts(tank[0]);
        add_tank_parts(tank[1]);

        from c=0 to 7;
            R=3000;
            ang=c*45000-22500;
            init_box(100,100,50+50*rand(0,2),GET_DISTX(ang,r+1000*rand(-1,1)),0,get_disty(ang,r+1000*rand(-1,1)),ang,green);
            init_box(100,100,50+50*rand(0,2),GET_DISTX(ang,r+8000*rand(-1,1)),0,get_disty(ang,r+8000*rand(-1,1)),ang,green);

            ang+=22500;
            init_box(50,200,100,GET_DISTX(ang,r+4000),0,get_disty(ang,r+4500),ang,green);
            r=6000;

        END
        for(c=0; c<6; c+=1)
            SHELL[c]=obj_count;
            init_shell(5,5,5,00,10000,00,0,white);
        END


        player[0]=obj_count;
        init_player(0,10,8,12,-100,100,0,0,green,0);
        player[1]=obj_count;
        init_player(1,10,8,12,100,100,0,0,green,0);




        init_shell_powerup(0);
        init_fuel_powerup(0);
        mini=2;
        init_fuel_powerup(mini);
        init_shell_powerup(mini);


        draw_perimeter(0);
        draw_perimeter(1);
    END
//--------------------------------------------------------------------------------

process init_tank(x0,y0,z0,ang,col)

    PRIVATE x0; y0; z0; i; j; k;  l;
        verts; edges; faces;  f=0; g; half_v; v; sx; sz;
    BEGIN
        verts=22;
        v=8;  //number of verts on draw edges
        half_v=v/2;
        edges=12;
        faces=6;
        edges=18;
        graph=20;    g=graph;
        getpoint(0,0,g);
        getpoint(1,1,g);
        getpoint(2,2,g);
        getpoint(3,6,g);
        getpoint(4,7,g);
        getpoint(5,8,g);
        getpoint(6,9,g);
        getpoint(7,13,g);
        getpoint(8,14,g);
        getpoint(9,24,g);
        getpoint(10,25,g);
        assignFaceEdgeIndices();
        build_objectf(obj_count,verts,edges,faces,col);
        obj[obj_count].col0=col;
        obj[obj_count].inradar=1;
        sz=tmp_vertex[2].z-tmp_vertex[3].z;
        sx=tmp_vertex[2].x-tmp_vertex[6].x;
        sz=222;
        sx=174;
        if(tank_count==0)
            ctank_graph[tank_count]=new_map(sx,sz,87,125,202);
        ELSE
            ctank_graph[tank_count]=new_map(sx,sz,87,125,230);
        END
        tank_id[tank_count]=tankobj(obj_count,tank_count,verts,edges,faces,x0,y0,z0,ang,col);
        obj_count+=1;
        tank_count+=1;
    END
 //---------------------------------------------------------------------------------------------------

PROCESS assignFaceEdgeIndices()
    private
        f;
    BEGIN
        tmp_edge[1].v0=1; tmp_edge[1].v1=2;
        tmp_edge[2].v0=2; tmp_edge[2].v1=3;
        tmp_edge[3].v0=3; tmp_edge[3].v1=4;
        tmp_edge[4].v0=4; tmp_edge[4].v1=1;
        tmp_edge[5].v0=5; tmp_edge[5].v1=6;
        tmp_edge[6].v0=6; tmp_edge[6].v1=7;
        tmp_edge[7].v0=7; tmp_edge[7].v1=8;
        tmp_edge[8].v0=8; tmp_edge[8].v1=5;
        tmp_edge[9].v0=1; tmp_edge[9].v1=5;
        tmp_edge[10].v0=2; tmp_edge[10].v1=6;
        tmp_edge[11].v0=3; tmp_edge[11].v1=7;
        tmp_edge[12].v0=4; tmp_edge[12].v1=8;
        tmp_edge[13].v0=17; tmp_edge[13].v1=11;
        tmp_edge[14].v0=18; tmp_edge[14].v1=12;
        tmp_edge[15].v0=19; tmp_edge[15].v1=13;
        tmp_edge[16].v0=20; tmp_edge[16].v1=14;
        tmp_edge[17].v0=21; tmp_edge[17].v1=15;
        tmp_edge[18].v0=22; tmp_edge[18].v1=16;
        f=0;
        f+=1;
        makeface(f,14,8,7,6,5,4);
        f+=1;
        makeface(f,13,1,4,3,2,4);
        f+=1;
        makeface(f,15,1,10,5,9,4);
        f+=1;
        makeface(f,17,3,12,7,11,4);
        f+=1;
        makeface(f,16,2,11,6,10,4);
        f+=1;
        makeface(f,18,4,9,8,12,4);
        getfacenormalvector(17,11,1,2,3,4);
        getfacenormalvector(18,12,8,7,6,5);
        getfacenormalvector(19,13,1,5,6,2);
        getfacenormalvector(20,14,2,6,7,3);
        getfacenormalvector(21,15,3,7,8,4);
        getfacenormalvector(22,16,4,8,5,1);
    END


//---------------------------------------------------------------------------------------------------

process makeface(f,a,b,c,d,e,n)

    BEGIN
        tmp_face[f].e[0]=a;
        tmp_face[f].e[1]=b;
        tmp_face[f].e[2]=c;
        tmp_face[f].e[3]=d;
        if(n==4)
            tmp_face[f].e[4]=e;
        END
    END
//---------------------------------------------------------------------------------------------------

PROCESS getfacenormalvector(v0,v1,a,b,c,d)
    PRIVATE
        x1,y1,z1,x2,y2,z2;
    BEGIN
        getfacecentrevertex(v1,a,b,c,d);
        x1=tmp_vertex[a].x-tmp_vertex[b].x;
        y1=tmp_vertex[a].y-tmp_vertex[b].y;
        z1=tmp_vertex[a].z-tmp_vertex[b].z;
        x2=tmp_vertex[c].x-tmp_vertex[b].x;
        y2=tmp_vertex[c].y-tmp_vertex[b].y;
        z2=tmp_vertex[c].z-tmp_vertex[b].z;
        tmp_vertex[v0].x=tmp_vertex[v1].x-(y1*z2-z1*y2)/100;
        tmp_vertex[v0].y=tmp_vertex[v1].y-(z1*x2-x1*z2)/100;
        tmp_vertex[v0].z=tmp_vertex[v1].z-(x1*y2-y1*x2)/100;
    END

//--------------------------------------------------------------------------------
PROCESS getfacecentrevertex(v,a,b,c,d);
    BEGIN
        tmp_vertex[v].x=(tmp_vertex[a].x+tmp_vertex[b].x+tmp_vertex[c].x+tmp_vertex[d].x)/4;
        tmp_vertex[v].y=(tmp_vertex[a].y+tmp_vertex[b].y+tmp_vertex[c].y+tmp_vertex[d].y)/4;
        tmp_vertex[v].z=(tmp_vertex[a].z+tmp_vertex[b].z+tmp_vertex[c].z+tmp_vertex[d].z)/4;
    END
//--------------------------------------------------------------------------------

PROCESS getpoint(v,cp,graph)
    PRIVATE
        empty;
    BEGIN
        x=0; y=0;
        get_real_point(cp,&tmp_vertex[v].z,&tmp_vertex[v].y);
        tmp_vertex[v].y=-tmp_vertex[v].y;
        graph+=1;
        get_real_point(cp,&tmp_vertex[v].x,&empty);
    END
//____________________________________________________________________________________________________

function get_objdata(set,fraction)
private
    g; dx; dy; dz; i;
begin
    switch (set)
        case 1:     //shell powerup casing
            graph=15;    g=graph;
            getpoint(0,0,g);
            getpoint(1,1,g);
            getpoint(2,2,g);
            getpoint(3,3,g);
            getpoint(4,4,g);
            getpoint(5,5,g);
            getpoint(6,6,g);
            getpoint(7,7,g);
            getpoint(8,8,g);
            getpoint(9,9,g);
            //TRANSFORS THE VERT COORRDNIATES TO HAVE v0 AT LOCAL 0,0,0
            dx=tmp_vertex[0].x;
            dy=tmp_vertex[0].y;
            dz=tmp_vertex[0].z;
            for(i=0; i<=9; i+=1)
                tmp_vertex[i].x-=dx;
                tmp_vertex[i].y-=dy;
                tmp_vertex[i].z-=dz;
            END
        end
        case 2:
//top bit         //shell powerup projectile
            graph=15;    g=graph;
            getpoint(0,0,g);
            getpoint(1,3,g);
            getpoint(2,4,g);
            getpoint(3,8,g);
            getpoint(4,7,g);
            getpoint(5,10,g);
            getpoint(6,9,g);
            getpoint(7,11,g);
            getpoint(8,12,g);
//TRANSFORS THE VERT COORRDNIATES TO HAVE v0 AT LOCAL 0,0,0
            dx=tmp_vertex[0].x;
            dy=tmp_vertex[0].y;
            dz=tmp_vertex[0].z;
            for(i=0; i<=9; i+=1)
                tmp_vertex[i].x-=dx;
                tmp_vertex[i].y-=dy;
                tmp_vertex[i].z-=dz;
            END
         END
        case 3:
//fuelcan
            graph=17;    g=graph;
            getpoint(0,0,g);
            getpoint(1,1,g);
            getpoint(2,2,g);
            getpoint(3,3,g);
            getpoint(4,4,g);
            getpoint(5,5,g);
            getpoint(6,6,g);
            getpoint(7,7,g);
            getpoint(8,8,g);
//TRANSFORS THE VERT COORRDNIATES TO HAVE v0 AT LOCAL 0,0,0
            dx=tmp_vertex[0].x;
            dy=tmp_vertex[0].y;
            dz=tmp_vertex[0].z;
            for(i=0; i<=9; i+=1)
                tmp_vertex[i].x-=dx;
                tmp_vertex[i].y-=dy;
                tmp_vertex[i].z-=dz;
            END
         END
         case 4:
            graph=17;    g=graph;
            getpoint(0,0,g);
            getpoint(1,9,g);
            getpoint(2,10,g);
            getpoint(3,11,g);
            getpoint(4,12,g);
            getpoint(5,13,g);
            getpoint(6,14,g);
            getpoint(7,15,g);
            getpoint(8,16,g);
//TRANSFORS THE VERT COORRDNIATES TO HAVE v0 AT LOCAL 0,0,0
            dx=tmp_vertex[0].x;
            dy=tmp_vertex[0].y;
            dz=tmp_vertex[0].z;
            for(i=0; i<=9; i+=1)
                tmp_vertex[i].x-=dx;
                tmp_vertex[i].y-=dy;
                tmp_vertex[i].z-=dz;
            END
        END
        case 5:    //tank hull
            graph=20;    g=graph;
            getpoint(0,24,g);
            getpoint(1,2,g);
            getpoint(2,3,g);
            getpoint(3,5,g);
            getpoint(4,6,g);
            getpoint(5,9,g);
            getpoint(6,10,g);
            getpoint(7,12,g);
            getpoint(8,13,g);
//TRANSFORS THE VERT COORRDNIATES TO HAVE v0 AT LOCAL 0,0,0
            dx=tmp_vertex[0].x;
            dy=tmp_vertex[0].y;
            dz=tmp_vertex[0].z;
            for(i=0; i<=8; i+=1)
                tmp_vertex[i].x-=dx;
                tmp_vertex[i].y-=dy;
                tmp_vertex[i].z-=dz;
            END


        END
        case 6:  //tank turret
            graph=20;    g=graph;
            getpoint(0,25,g);
            getpoint(1,3,g);
            getpoint(2,28,g);
            getpoint(3,4,g);
            getpoint(4,5,g);
            getpoint(5,10,g);
            getpoint(6,29,g);
            getpoint(7,11,g);
            getpoint(8,12,g);
            getpoint(9,27,g);
            dx=tmp_vertex[0].x;
            dy=tmp_vertex[0].y;
            dz=tmp_vertex[0].z;
            for(i=0; i<=9; i+=1)
                tmp_vertex[i].x-=dx;
                tmp_vertex[i].y-=dy;
                tmp_vertex[i].z-=dz;
            END
        END
        case 8:
            graph=20;    g=graph;
            getpoint(0,26,g);
            getpoint(1,15,g);
            getpoint(2,16,g);
            getpoint(3,17,g);
            getpoint(4,18,g);
            getpoint(5,19,g);
            getpoint(6,20,g);
            getpoint(7,21,g);
            getpoint(8,22,g);
            dx=tmp_vertex[0].x;
            dy=tmp_vertex[0].y;
            dz=tmp_vertex[0].z;
            for(i=0; i<=8; i+=1)
                tmp_vertex[i].x-=dx;
                tmp_vertex[i].y-=dy;
                tmp_vertex[i].z-=dz;
            END

        END
        default: end
    end

    if(fraction<>0)
            for(i=0; i<=9; i+=1)
                tmp_vertex[i].x/=fraction;
                tmp_vertex[i].y/=fraction;
                tmp_vertex[i].z/=fraction;
            END
    END

end

//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
PROCESS init_shell_powerup(mini);
    PRIVATE
        x0; y0; z0; i; j; k;  l; ang;
        col;
        verts=22;
        edges=18;
        faces=6;

        g; half_v; v; fix; dx; dy; dz; parent;
BEGIN
    col=white;
    get_objdata(1,mini);
    AssignFaceEdgeIndices();
    switch(mini)
        case 2:
            for(c=0; c<=1; c+=1)
                build_objectf(obj_count,verts,edges,faces,col);
                s_minishell[c].part[0]=obj_count;
                s_minishell[c].part_id[0]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,c);
                s_minishell[c].part_id[0].priority=player_id[c].priority-1;
                obj_count+=1;

            END
        END
        case 0:
            build_objectf(obj_count,verts,edges,faces,col);
            shellpwr_id[0]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,-3);
            obj_pwrshell[0]=obj_count;
            obj[obj_pwrshell[0]].fogme=1;
            obj[obj_pwrshell[0]].inradar=1;
            obj[obj_pwrshell[0]].col0=white;
            obj_count+=1;

        END
        default: END
    EnD
    get_objdata(2,mini);
    AssignFaceEdgeIndices();
    switch(mini)
        case 2:
            for(c=0; c<=1; c+=1)
                build_objectf(obj_count,verts,edges,faces,col);
                s_minishell[c].part[1]=obj_count;
                s_minishell[c].part_id[1]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,obj_count-2);
                s_minishell[c].part_id[1].priority=player_id[c].priority-1;
                obj_count+=1;
            END
        END
        case 0:
            build_objectf(obj_count,verts,edges,faces,col);
            shellpwr_id[1]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,obj_count-1);
            obj_pwrshell[1]=obj_count;
            obj[obj_pwrshell[1]].fogme=1;
            obj[obj_pwrshell[1]].col0=white;
            obj_count+=1;
        END
        default:
        END
    END
END


//--------------------------------------------------------------------------------------

PROCESS init_fuel_powerup(mini);

PRIVATE
    x0; y0; z0; i; j; k;  l; ang; col;
    verts=22;
    edges=18;
    faces=6;
    g; half_v; v; fix; dx; dy; dz; parent;

BEGIN
    col=white;
//powerup can

    get_objdata(3,mini);
    AssignFaceEdgeIndices();
    switch(mini)
        case 2:
            for(c=0; c<=1; c+=1)
                build_objectf(obj_count,verts,edges,faces,col);
                s_minifuel[c].part[0]=obj_count;
                s_minifuel[c].part_id[0]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,c);
                s_minifuel[c].part_id[0].priority=player_id[c].priority-1;
                obj_count+=1;
            END
        END
        case 0:
            build_objectf(obj_count,verts,edges,faces,col);
            fuelpwr_id[0]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,-3);
            obj_pwrfuel[0]=obj_count;
            obj[obj_pwrfuel[0]].fogme=1;
            obj[obj_pwrfuel[0]].inradar=1;
            obj[obj_pwrfuel[0]].col0=white;
            obj_count+=1;
        END
        default: END
    EnD
//top bit
    get_objdata(4,mini);
    AssignFaceEdgeIndices();
    switch(mini)
        case 2:
            for(c=0; c<=1; c+=1)
                build_objectf(obj_count,verts,edges,faces,col);
                s_minifuel[c].part[1]=obj_count;
                s_minifuel[c].part_id[1]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,obj_count-2);
                s_minifuel[c].part_id[0].priority=player_id[c].priority-1;
                obj_count+=1;
            END
        END
        case 0:
            build_objectf(obj_count,verts,edges,faces,col);
            fuelpwr_id[1]=pwrup(obj_count,verts,edges,faces,x0,y0,z0,ang,col,obj_count-1);
            obj_pwrfuel[1]=obj_count;
            obj[obj_pwrfuel[1]].fogme=1;
            obj[obj_pwrfuel[1]].col0=white;
            obj_count+=1;
        END
        default:
        END
    END
END



//--------------------------------------------------------------------------------

PROCESS pwrup(n,verts,edges,fasces,x0,y0,z0,ang0,col,parent_n);

private
 d;i; pl; ta;   sinA; cosA;
BEGIN
    if(parent_n==-3)
        graph=104;
        ctype=c_scroll;
    repeat
       angle=rand(0,360000);
       d=rand(0,12000);
       obj[n].posx=get_distx(angle,d);
       obj[n].posz=get_disty(angle,d);
       x=obj[n].posx;
       y=obj[n].posz;
    until(not collision(type box))

    END
    renderme=draw_objf(n,1,1);
    obj[n].posy=0;
    state=out;
    loop
        switch(id)
            case shellpwr_id[0],fuelpwr_id[0]:
                ta= collision(type tankobj);
                if(ta<>0)
                    if(id==shellpwr_id[0])
                        score.shells[i]=score.ammo0;
                    ELSE
                        score.fuel[i]=score.fuel0;
                    end
                END
                pl=collision(type player_obj);
                if(pl<>0)
                if((pl==player_id[0] or pl==player_id[1]) and pl.state<>kamikazi)
                    if(id==shellpwr_id[0])
                        if(pl.state==got_fuel)
                            s_minifuel[pl.index].part_id[0].state=out;
                        END
                        pl.state=got_shell;
                        s_minishell[pl.index].part_id[0].state=pl;
                    ELSE
                        if(pl.state==got_shell)
                            s_minishell[pl.index].part_id[0].state=out;
                        END
                        pl.state=got_fuel;
                        s_minifuel[pl.index].part_id[0].state=pl;
                    END


                END
                END
                if(pl<>0 or ta<>0)
                    repeat
                        angle=rand(0,360000);
                        d=rand(0,12000);
                        obj[n].posx=get_distx(angle,d);
                        obj[n].posz=get_disty(angle,d);
                        x=obj[n].posx;
                        y=obj[n].posz;
                    until(not collision(type box))
                END
                obj[n].angley+=3000;
                if(obj[n].angley>=360000)
                    obj[n].angley-=360000;
                END
            end

            case s_minishell[0].part_id[0],s_minishell[1].part_id[0]:
                if(state==out)
                    obj[n].posy=1000;
                    obj[n].invisible[0]=1;
                    obj[n].invisible[1]=1;
                else
                    obj[n].invisible[0]=0;
                    obj[n].invisible[1]=0;

                END


            END

            case s_minifuel[0].part_id[0], s_minifuel[1].part_id[0]:
                if(state==out)
                    obj[n].posy=1000;
                    obj[n].invisible[0]=1;
                    obj[n].invisible[1]=1;
                else
                    obj[n].invisible[0]=0;
                    obj[n].invisible[1]=0;

                END
            END

            case shellPWR_ID[1],fuelPWR_ID[1],  s_minifuel[0].part_id[1],  s_minifuel[1].part_id[1]:
                obj[n].posx=obj[parent_n].posx;
                obj[n].posy=obj[parent_n].posy;
                obj[n].posz=obj[parent_n].posz;
                obj[n].angley=obj[parent_n].angley;
                obj[n].anglex=obj[parent_n].anglex;
                obj[n].invisible[0]=obj[parent_n].invisible[0];
                obj[n].invisible[1]=obj[parent_n].invisible[1];



            END

            case  s_minishell[0].part_id[1], s_minishell[1].part_id[1]:
                obj[n].posx=obj[parent_n].posx;
                obj[n].posy=obj[parent_n].posy;
                obj[n].posz=obj[parent_n].posz;
                obj[n].angley=obj[parent_n].angley;
                obj[n].anglex=obj[parent_n].anglex;
                obj[n].invisible[0]=obj[parent_n].invisible[0];
                obj[n].invisible[1]=obj[parent_n].invisible[1];


            END

            default: end
        END
        position_obj(n,obj[n].posx,obj[n].posy,obj[n].posz);
        rotate_objxyz(n,0,0,0);
        angle=obj[n].angley;
        x=obj[n].posx;
        y=obj[n].posz;

        frame;
    end
END
//--------------------------------------------------------------------------------

PROCESS add_tank_parts(n)
PRIVATE
    x0; y0; z0; i; j; k;  l; ang; col;
    verts; edges; g;  half_v; v; fix; dx; dy; dz; parent; faces; sx; sz;
BEGIN
    col=obj[tank[n]].col0;
//_______HULL_______________________________________
    verts=22;
    edges=18;
    faces=6;
    get_objdata(5,0);
    AssignFaceEdgeIndices();
    build_objectf(obj_count,verts,edges,faces,col);
    fix=9; parent=n;
    hull_id[n]=tank_part(obj_count,verts,edges,faces,x0,y0,z0,ang,n,1,parent,fix,col,0);
    HULL[n]=obj_count;
    obj_count+=1;

//-TURRET------------------------------------------
    verts=22;
    edges=18;
    faces=6;
    get_objdata(6,0):
    AssignFaceEdgeIndices();
    build_objectf(obj_count,verts,edges,faces,col);
    fix=10;  parent=n;
    turret_id[n]=tank_part(obj_count,verts,edges,faces,x0,y0,z0,ang,n,2,parent,fix,col,100);
    TURRET[n]=obj_count;
    obj_count+=1;

//-----SHAFT--------------------------------------
    verts=2;
    v=verts;;  //number of verts on draw edges
    half_v=v/2;
    edges=1;
    graph=20;    g=graph;
    getpoint(0,27,g);
    getpoint(1,26,g);
    x=tmp_vertex[0].x;
    dy=tmp_vertex[0].y;
    dz=tmp_vertex[0].z;
    for(i=0; i<=verts; i+=1)
        tmp_vertex[i].x-=dx;
        tmp_vertex[i].y-=dy;
        tmp_vertex[i].z-=dz;
    END
    tmp_edge[1].v0=0; tmp_edge[1].v1=1;
    build_objectf(obj_count,verts,edges,faces,col);
    fix=9;  parent=obj_count-1;
    SHAFT[n]=obj_count;
    shaft_id[n]=tank_part(obj_count,verts,edges,faces,x0,y0,z0,ang,n,3,parent,fix,col,100);
    obj_count+=1;

//-BARREL------------------------------------------

    verts=22;
    edges=18;
    faces=6;
    get_objdata(8,0);
    AssignFaceEdgeIndices();
    build_objectf(obj_count,verts,edges,faces,col);
    fix=1;  parent =obj_count-1;
    BARREL[n]=obj_count;
    barrel_id[n]=tank_part(obj_count,verts,edges,faces,x0,y0,z0,ang,n,4,parent,fix,col,100);
    obj_count+=1;

//-------------------------------------------
//RADAR POST

    verts=2;
    v=verts;;  //number of verts on draw edges
    half_v=v/2;
    edges=1;
    faces=0;
    graph=20;    g=graph;
    getpoint(0,4,g);
    tmp_vertex[1].x=tmp_vertex[0].x;
    tmp_vertex[1].y=tmp_vertex[0].y+10;
    tmp_vertex[1].z=tmp_vertex[0].z;
    dx=tmp_vertex[0].x;
    dy=tmp_vertex[0].y;
    dz=tmp_vertex[0].z;
    for(i=0; i<=verts; i+=1)
        tmp_vertex[i].x-=dx;
        tmp_vertex[i].y-=dy;
        tmp_vertex[i].z-=dz;
    END
    tmp_edge[1].v0=0; tmp_edge[1].v1=1;
    build_objectf(obj_count,verts,edges,faces,col);
    fix=2;  parent=turret[n];
    post_id[n]=tank_part(obj_count,verts,edges,faces,x0,y0,z0,ang,n,5,parent,fix,col,100);
    POST[n]=obj_count;
    obj_count+=1;

//-------------------------------------------
 //RADAR DISH
    verts=8;
    v=8;
    half_v=v/2;
    verts=20;
    edges=16;
    faces=6;
    graph=22; g=graph;
    getpoint(0,0,g);
    getpoint(1,1,g);
    getpoint(2,2,g);
    getpoint(3,3,g);
    getpoint(4,4,g);
    getpoint(5,5,g);
    getpoint(6,6,g);
    getpoint(7,7,g);
    getpoint(8,8,g);
    tmp_edge[1].v0=1 ; tmp_edge[1].v1=2;
    tmp_edge[2].v0=2 ; tmp_edge[2].v1=3;
    tmp_edge[3].v0=3 ; tmp_edge[3].v1=4;
    tmp_edge[4].v0=4 ; tmp_edge[4].v1=5;
    tmp_edge[5].v0=5 ; tmp_edge[5].v1=6;
    tmp_edge[6].v0=6 ; tmp_edge[6].v1=7;
    tmp_edge[7].v0=7 ; tmp_edge[7].v1=8;
    tmp_edge[8].v0=8 ; tmp_edge[8].v1=1;
    tmp_edge[9].v0=2 ; tmp_edge[9].v1=7;
    tmp_edge[10].v0=3 ; tmp_edge[10].v1=6;
    tmp_edge[11].v0=9 ; tmp_edge[11].v1=10;
    tmp_edge[12].v0=11 ; tmp_edge[12].v1=12;
    tmp_edge[13].v0=13 ; tmp_edge[13].v1=14;
    tmp_edge[14].v0=15 ; tmp_edge[14].v1=16;
    tmp_edge[15].v0=17; tmp_edge[15].v1=18;
    tmp_edge[16].v0=19 ; tmp_edge[16].v1=20;
    makeface(1,11,1,9,7,8,4);
    makeface(2,12,2,10,6,9,4);
    makeface(3,13,3,4,5,10,4);
    makeface(4,14,3,10,5,4,4);
    makeface(5,15,2,9,6,10,4);
    makeface(6,16,1,8,7,9,4);
    getfacecentrevertex(9,1,2,7,8);
    getfacecentrevertex(11,2,3,6,7);
    getfacecentrevertex(13,3,4,5,6);
    getfacecentrevertex(15,3,4,5,6);
    getfacecentrevertex(17,2,3,6,7);
    getfacecentrevertex(19,1,2,7,8);
    getfacenormalvector(9,10,1,2,7,8);
    getfacenormalvector(11,12,2,3,6,7);
    getfacenormalvector(13,14,3,4,5,6);
    getfacenormalvector(15,16,3,6,5,4);
    getfacenormalvector(17,18,2,7,6,3);
    getfacenormalvector(19,20,1,8,7,2);
    build_objectf(obj_count,verts,edges,faces,col);
    fix=1; parent =post[n];
    dish_id[n]= tank_part(obj_count,verts,edges,faces,x0,y0,z0,ang,n,6,parent,fix,col,100);
    dish[n]=obj_count;
    obj_count+=1;
END

//----------------------------------------------------------------------------------------------------------------------

PRocess init_plane(w,h,x0,y0,z0,ang,col)
PRIVATE
    i; j; k;  l; verts; edges; faces;  ang;  rad; id2;
BEGIN
    obj[obj_count].col0=col;
    verts=5;
    edges=5;
    FACES=1;
    tmp_vertex[0].x=0: tmp_vertex[0].y=0; tmp_vertex[0].z=0;
    tmp_vertex[1].x=w: tmp_vertex[1].y=h; tmp_vertex[1].z=0;
    tmp_vertex[2].x=-w: tmp_vertex[2].y=h; tmp_vertex[2].z=0;
    tmp_vertex[3].x=-w: tmp_vertex[3].y=-h; tmp_vertex[3].z=0;
    tmp_vertex[4].x=w: tmp_vertex[4].y=-h; tmp_vertex[4].z=0;
    tmp_vertex[5].x=0: tmp_vertex[5].y=0; tmp_vertex[5].z=-100;
    tmp_edge[1].v0=1; tmp_edge[1].v1=2;
    tmp_edge[2].v0=2; tmp_edge[2].v1=3;
    tmp_edge[3].v0=3; tmp_edge[3].v1=4;
    tmp_edge[4].v0=4; tmp_edge[4].v1=1;
    tmp_edge[5].v0=0; tmp_edge[5].v1=5;
    tmp_face[1].e[0]=5;
    tmp_face[1].e[1]=1;
    tmp_face[1].e[2]=2;
    tmp_face[1].e[3]=3;
    tmp_face[1].e[4]=4;
    build_objectf(obj_count,verts,edges,faces,col);
    id2=plane(obj_count,verts,edges,faces,x0,y0+h,z0,ang,col);
    obj_count+=1;
    return(id2);
END
//____________________________________________________________________________


PROCESS init_shell(w,d,h,x0,y0,z0,ang,col)
PRIVATE
    i; j; k;  l;  verts; edges; faces;
BEGIN
    obj[obj_count].col0=col;
    verts=22;
    edges=18;
    FACES=6;
    tmp_vertex[0].x=0: tmp_vertex[0].y=0; tmp_vertex[0].z=0;
    tmp_vertex[1].x=w: tmp_vertex[1].y=h; tmp_vertex[1].z=-d;
    tmp_vertex[2].x=-w: tmp_vertex[2].y=h; tmp_vertex[2].z=-d;
    tmp_vertex[3].x=-w: tmp_vertex[3].y=-h; tmp_vertex[3].z=-d;
    tmp_vertex[4].x=w: tmp_vertex[4].y=-h; tmp_vertex[4].z=-d;
    tmp_vertex[5].x=w: tmp_vertex[5].y=h; tmp_vertex[5].z=d;
    tmp_vertex[6].x=-w: tmp_vertex[6].y=h; tmp_vertex[6].z=d;
    tmp_vertex[7].x=-w: tmp_vertex[7].y=-h; tmp_vertex[7].z=d;
    tmp_vertex[8].x=w: tmp_vertex[8].y=-h; tmp_vertex[8].z=d;
    l=0;
    tmp_vertex[9].x=0:  tmp_vertex[9].y=0;   tmp_vertex[9].z=-(d+l);
    tmp_vertex[10].x=0:  tmp_vertex[10].y=0;  tmp_vertex[10].z=(d+l);
    tmp_vertex[11].x=0:  tmp_vertex[11].y=(h+l); tmp_vertex[11].z=0;
    tmp_vertex[12].x=0: tmp_vertex[12].y=-(h+l); tmp_vertex[12].z=0;
    tmp_vertex[13].x=(w+l):  tmp_vertex[13].y=0; tmp_vertex[13].z=0;
    tmp_vertex[14].x=-(w+l): tmp_vertex[14].y=0; tmp_vertex[14].z=0;
    assignFaceEdgeIndices();
    build_objectf(obj_count,verts,edges,faces,col);
    y0=h;
    shell_id[shell_count]=shellobj(shell_count);
    obj[obj_count].inradar=1;
    obj[obj_count].x0=x0;
    obj[obj_count].y0=y0;
    obj[obj_count].z0=z0;
    obj_count+=1;
    shell_count+=1;
END
//____________________________________________________________________________

PROCESS init_box(w,d,h,x0,y0,z0,ang,col)
PRIVATE
    i; j; k;  l; verts; edges; faces;  ang;  rad;
BEGIN
    obj[obj_count].col0=col;
    verts=22;
    edges=18;
    FACES=6;
    tmp_vertex[0].x=0: tmp_vertex[0].y=0; tmp_vertex[0].z=0;
    tmp_vertex[1].x=w: tmp_vertex[1].y=h; tmp_vertex[1].z=-d;
    tmp_vertex[2].x=-w: tmp_vertex[2].y=h; tmp_vertex[2].z=-d;
    tmp_vertex[3].x=-w: tmp_vertex[3].y=-h; tmp_vertex[3].z=-d;
    tmp_vertex[4].x=w: tmp_vertex[4].y=-h; tmp_vertex[4].z=-d;
    tmp_vertex[5].x=w: tmp_vertex[5].y=h; tmp_vertex[5].z=d;
    tmp_vertex[6].x=-w: tmp_vertex[6].y=h; tmp_vertex[6].z=d;
    tmp_vertex[7].x=-w: tmp_vertex[7].y=-h; tmp_vertex[7].z=d;
    tmp_vertex[8].x=w: tmp_vertex[8].y=-h; tmp_vertex[8].z=d;
    l=0;
    tmp_vertex[9].x=0:  tmp_vertex[9].y=0;   tmp_vertex[9].z=-(d+l);
    tmp_vertex[10].x=0:  tmp_vertex[10].y=0;  tmp_vertex[10].z=(d+l);
    tmp_vertex[11].x=0:  tmp_vertex[11].y=(h+l); tmp_vertex[11].z=0;
    tmp_vertex[12].x=0: tmp_vertex[12].y=-(h+l); tmp_vertex[12].z=0;
    tmp_vertex[13].x=(w+l):  tmp_vertex[13].y=0; tmp_vertex[13].z=0;
    tmp_vertex[14].x=-(w+l): tmp_vertex[14].y=0; tmp_vertex[14].z=0;
    assignFaceEdgeIndices();
    build_objectf(obj_count,verts,edges,faces,col);
    y0=h;
    obj[obj_count].c_id=box(obj_count,w,d,h,verts,edges,faces,x0,y0,z0,ang,col);
    obj[obj_count].inradar=0;
    obj[obj_count].x0=x0;
    obj[obj_count].y0=y0;
    obj[obj_count].z0=z0;
    obj_count+=1;
    box_count+=1;
END //PROC
 //-----------------------------------------------------------------------

PROCESS init_player(index,w,d,h,x0,y0,z0,ang,col,part)
PRIVATE
    i; j; k;  l; verts; edges; faces;  ang;  rad; bpart;
BEGIN
    obj[obj_count].col0=col;
    verts=22;
    edges=18;
    FACES=6;
    tmp_vertex[0].x=0: tmp_vertex[0].y=0; tmp_vertex[0].z=0;
    tmp_vertex[1].x=w: tmp_vertex[1].y=h; tmp_vertex[1].z=-d;
    tmp_vertex[2].x=-w: tmp_vertex[2].y=h; tmp_vertex[2].z=-d;
    tmp_vertex[3].x=-w: tmp_vertex[3].y=-h; tmp_vertex[3].z=-d;
    tmp_vertex[4].x=w: tmp_vertex[4].y=-h; tmp_vertex[4].z=-d;
    tmp_vertex[5].x=w: tmp_vertex[5].y=h; tmp_vertex[5].z=d;
    tmp_vertex[6].x=-w: tmp_vertex[6].y=h; tmp_vertex[6].z=d;
    tmp_vertex[7].x=-w: tmp_vertex[7].y=-h; tmp_vertex[7].z=d;
    tmp_vertex[8].x=w: tmp_vertex[8].y=-h; tmp_vertex[8].z=d;
    l=0;
    tmp_vertex[9].x=0:  tmp_vertex[9].y=0;   tmp_vertex[9].z=-(d+l);
    tmp_vertex[10].x=0:  tmp_vertex[10].y=0;  tmp_vertex[10].z=(d+l);
    tmp_vertex[11].x=0:  tmp_vertex[11].y=(h+l); tmp_vertex[11].z=0;
    tmp_vertex[12].x=0: tmp_vertex[12].y=-(h+l); tmp_vertex[12].z=0;
    tmp_vertex[13].x=(w+l):  tmp_vertex[13].y=0; tmp_vertex[13].z=0;
    tmp_vertex[14].x=-(w+l): tmp_vertex[14].y=0; tmp_vertex[14].z=0;
    assignFaceEdgeIndices();
    build_objectf(obj_count,verts,edges,faces,col);
    bpart=player_obj(index,obj_count,w,d,h,verts,edges,faces,x0,y0,z0,ang,col,part);
    obj[obj_count].fogme=1;
    switch (part)
        case 0:
            player_id[index]=bpart;
            body[index].torso_id=player_id[index];
            body[index].torso=obj_count;
            player[index]=obj_count;
            obj_count+=1;
            init_player(index,5,6,6,x0,y0,z0,ang,col,1);
        End
        case 1:
            body[index].head_id=bpart;
            body[index].head=obj_count;
            obj_count+=1;
            init_player(index,4,4,10,x0,y0,z0,ang,col,2);

        END
        case 2:
            body[index].leg_r_id=bpart;
            body[index].leg_r=obj_count;
            obj_count+=1;
            init_player(index,4,4,10,x0,y0,z0,ang,col,3);
        END
        case 3:
            body[index].leg_l_id=bpart;
            body[index].leg_l=obj_count;
            obj_count+=1;
            init_player(index,4,4,10,x0,y0,z0,ang,col,4);
        END
        case 4:
            body[index].arm_r_id=bpart;
            body[index].arm_r=obj_count;
            obj_count+=1;
            init_player(index,4,4,10,x0,y0,z0,ang,col,5);
        END
        case 5:
            body[index].arm_l_id=bpart;
            body[index].arm_l=obj_count;
            obj_count+=1;
        END
        default:
        end
    end
END //PROC
//---------------------------------------------------------------------------------------

PROCESS shellobj(n)
PRIVATE
    status; velh; velv; col0; travel; x0; z0; y0; sx0; sy0; sz0; x1; z1;y1;
    dist;  vel;  hit_box; hit_tank; dx; dz; steps; n1; radi;   graph0;      hit;
BEGIN
    renderme=draw_objf(shell[n],1,1);
    steps=50;
    vel=10000/steps;
    n1=n mod 2;
    status=0;
    col0=obj[shell[n]].col0;
    graph=103;
    ctype=c_scroll;
    status=2;
    gunstate[n1]=0;
    timer[n]=0;
    Position_obj(SHELL[n],obj[BARREL[n1]].vertex[0].x,obj[BARREL[n1]].vertex[0].y+10000,obj[BARREL[n1]].vertex[0].z);
    obj[shell[n]].invisible[0]=1;
    obj[shell[n]].invisible[1]=1;

    y=10000;
    LOOP
        switch(status)
            case 0:
                obj[shell[n]].col0=white;
                obj[shell[n]].invisible[0]=1;
                obj[shell[n]].invisible[1]=1;
                if(key(fire[n1]) and not key(ctrl[n1]))
                    timer[n]=0;
                    if(tank_id[n1].state==action and score.shells[n1]>0 and gunstate[n1]==1)
                        gunstate[n1]=2;
                        score.shells[n1]-=1;
                        sound(snd_shoot,256,256);
                        Position_obj(SHELL[n],obj[BARREL[n1]].vertex[0].x,obj[BARREL[n1]].vertex[0].y,obj[BARREL[n1]].vertex[0].z);
                        obj[shell[n]].angley=obj[turret[n1]].angley;
                        obj[shell[n]].anglex=obj[barrel[n1]].anglex;
                        rotate_objxyz(SHELL[n],0,0,0);
                        castlight(obj[shell[n]].posx,obj[shell[n]].posy,obj[shell[n]].posz,32,500);
                        dist=0;
                        velh= get_distx(obj[shell[n]].anglex,vel);
                        velv= -get_disty(obj[shell[n]].anglex,vel);
                        status=1;
                        x=obj[shell[n]].posx;
                        z=obj[shell[n]].posy;
                        y=obj[shell[n]].posz;
                        angle=obj[shell[n]].angley+90000;
                        col0=green;
                        defog(tank[n1],10);
                        defog(hull[n1],10);
                        defog(turret[n1],10);
                        defog(barrel[n1],10);
                        defog(dish[n1],10);
                        obj[shell[n]].invisible[0]=0;
                        obj[shell[n]].invisible[1]=0;

                    END
                END
            END
            case 1:
                if(gunstate[n1]==2)
                    gunstate[n1]=0;
                    timer[n]=0;
                END
                sx0=x; sy0=z; sz0=y;
                IF(z>0)
                    move_objxz(shell[n],velh);
                    move_objy(shell[n],velv);
                    for(c=1; c<=steps; c+=1)
                        x=sx0+c*(obj[shell[n]].posx-sx0)/steps;
                        z=sy0+c*(obj[shell[n]].posy-sy0)/steps;
                        y=sz0+c*(obj[shell[n]].posz-sz0)/steps;
                        hit_box=(collision(type box));
                        if(hit_box)
                            if(hit_box.height>z/2)
                                explosionF(obj[shell[n]].posx,obj[shell[n]].posy,obj[shell[n]].posz,8,cyan0,cyan);
                                castlight(obj[shell[n]].posx,obj[shell[n]].posy,obj[shell[n]].posz,64,500);
                                status=2;
                                break;
                            END
                        END
                        hit_tank=collision(type tankobj);
                        if(hit_tank==tank_id[n1])
                            hit_tank=collision(type tankobj);
                        END
                        if(hit_tank)
                            if(hit_tank.state==action or hit_tank.state==onfoot)
                                dx=(obj[tank[1-n1]].posx-obj[shell[n]].posx)*(obj[tank[1-n1]].posx-obj[shell[n]].posx);
                                dz=(obj[tank[1-n1]].posz-obj[shell[n]].posz)*(obj[tank[1-n1]].posz-obj[shell[n]].posz);
                                if(z<80 or (z<120 and dx+dz<2500))
                                    explosionF(obj[shell[n]].posx,obj[shell[n]].posy,obj[shell[n]].posz,8,cyan0,cyan);
                                    castlight(obj[shell[n]].posx,obj[shell[n]].posy,obj[shell[n]].posz,64,1000);
                                    Position_obj(SHELL[n],obj[BARREL[n1]].vertex[0].x,obj[BARREL[n1]].vertex[0].y+1000,obj[BARREL[n1]].vertex[0].z);
                                    status=2;
                                    //if(hit_tank.state==action)
                                    //    player_id[1-n1].state=dead;
                                    //END
                                    hit_tank.state=boom;
                                    break;
                                END
                            END
                        END

                    END
                    If( travel==0)
                        x0=obj[shell[n]].vertex[0].x;
                        y0=obj[shell[n]].vertex[0].y;
                        z0=obj[shell[n]].vertex[0].z;
                    END
                    travel+=1;
                    x1=obj[shell[n]].vertex[0].x;
                    y1=obj[shell[n]].vertex[0].y;
                    z1=obj[shell[n]].vertex[0].z;
                    if(y1>0)
                        for(c=0; c<4; c+=1)
                            tracer(x0,y0,z0,
                            x1+rand(-4,4),y1+rand(-4,4),z1+rand(-4,4),cyan,cyan0,8);
                        end

                    END
                    x0=x1; y0=y1; z0=z1;
                    IF(Travel mod 2 ==0)
                        IF(Travel mod 4 ==0)
                            if(velh>0)
                                velh-=100/steps;
                            END
                            velv-=200/steps;
                        END
                    END
                else
                    explosionF(obj[shell[n]].posx,obj[shell[n]].posy,obj[shell[n]].posz,24,cyan0,cyan);
                    blastradius(x,y);
                    hit_box=collision(type oilpatch);
                    if(hit_box)
                        igniteoil(x,y,hit_box);
                    END

                    if(get_dist(player_id[1-n1])<400)
                        if(player_id[1-n1].state==onfoot
                        or player_id[1-n1].state==got_fuel
                        or player_id[1-n1].state==got_shell
                        or player_id[1-n1].state==kamikazi
                        or player_id[1-n1].state==hopping)
                            player_id[1-n1].state=boom;
                        end
                    END
                    castlight(obj[shell[n]].posx,obj[shell[n]].posy,obj[shell[n]].posz,64,1800);
                    velv=0;
                    if(velv==0)
                        status=2;

                    end
                    hit_box=0;   hit_tank=0;
                    x=obj[shell[n]].posx;
                    y=obj[shell[n]].posz;
                    z=obj[shell[n]].posy;
                END
            END
            case 2:
                Position_obj(SHELL[n],obj[BARREL[n1]].vertex[0].x,obj[BARREL[n1]].vertex[0].y+1000,obj[BARREL[n1]].vertex[0].z);
                hit_box=0;
                hit_tank=0;
                travel=0;

                obj[shell[n]].invisible[0]=1;
                obj[shell[n]].invisible[1]=1;
                if(gunstate[n1]==2)
                    timer[n]=0;
                END
                if(gunstate[n1]==0)
                    if(timer[n]>100 and score.shells[n1]>0)
                        gunstate[n1]=1;
                        status=0;
                    END
                END
            end
            default:
            END
        END  //Switch
        FRAME;
    END
END
//___________________________________________________________________________________

PRocess defog(n,t)
begin
    obj[n].fogme=0;
    for(c=1; c<=t; c+=1)
        FRAME;
    end
    obj[n].fogme=1;
END
//___________________________________________________________________________________
process explosionF(x,y,z,count,col0,col1)

Begin
    if(y<0) y=1; end
    for(c=0; c<count; c+=1)
        fragment(x,y,z,c,col0,col1);
    END


END




//___________________________________________________________________________________

process fragment(x0,y0,z0,c,col0,col1);
private
    travel; x1;y1; z1; velh;  velv; velx; velz;  col; vel;
begin
    frag_count+=1;
    x1=x0; y1=y0; z1=z0;
    angle=rand(-90000,90000);
    vel=rand(140,180);
    velv=-get_disty(angle,vel);
    velh=get_distx(angle,vel);
    angle=rand(0,360000);
    col=col1;
    while(col>col0)
        if(col<col0)
            col=col0;
        END
        IF(Travel mod 2 ==0)
            col-=1;

            x1+=get_distx(angle,velh);
            y1+=velv;
            if(y1<0)
             y1=0;
             velv=-velv;
             break;
            END
            z1+=get_disty(angle,velh);
            if(y1>=0)
                tracer(x0,y0,z0,x1,y1,z1,col,col0,10);
            END
            if(velh>0)
                velh=9*velh/10;
            END
            //velv-=4;
                velv=9*velv/10;

            x0=x1; y0=y1; z0=z1;
        end



        frame;
        if(col==64)
            break;
        END
    END
    frag_count-=1;
end


//___________________________________________________________________________________

process flame(x,y,z,col,size,h);
private
px[1];
py[1];
pz[1];
i:
col0;
x0;
y0;
z0;
hit;
begin
ctype=c_scroll;
graph=107;
col0=col;
x0=x;
y0=y;
Z0=Z;
    while (col>123)
    if(col>140)
        z+=h;
        z0-=1;
        if(z0<0)z0=0; END

    else
        z-=2;
        z0+=2;
    end
        col0=col+rand(0,5);
        if(col0<=128) col0=0; END
            x=father.x; y=father.y;
            angle=father.angle;

            get_real_point(1, &px[0],&pz[0]);
            get_real_point(2, &px[1],&pz[1]);
            x0=x+rand(-size,size);
            y0=y+rand(-size,size);
            //draw_3dline(px[0],z+rand(0,10),pz[0],px[1],0,pz[1],1,1,col0,128,0);
            draw_3dline(px[0],z0,pz[0],x0,z,y0,1,1,col0,128,0);
            draw_3dline(x0,z,y0,px[1],z0,pz[1],1,1,col0,128,0);

            col-=2;
            from c=0 to 1;
                if(player_id[c].state<>onfire and player_id[c].state<>dead)
                    hit=get_dist(player_id[c]);
                    if(hit<100)
                        manfire(c);
                    end
                end
            end
        frame;
    end
    father.state-=1;
end
//___________________________________________________________________________________
process flame2(x1,y1,z1,x2,y2,z2,x3,y3,z3,col0,v)
private
col;
begin


while(col0>128)
y1+=v;
y2+=v;
y3+=2*v;
col0-=4;
col=col0+rand(0,4);
if(col<128) col=128; END
draw_3dline(x1,y1,z1,x3,y3,z3,1,1,col,128,0);
draw_3dline(x2,y2,z2,x3,y3,z3,1,1,col,128,0);
frame;
end
end


//___________________________________________________________________________________

process tankfire(index)
private
col0=170;
v1;
v2;
t;
i;
rx; rz;
col;
x1;
y1;
z1;
x2;
y2;
z2;
x3;
y3;
z3;

begin

while(t<30)
 col0-=1;
from v1=1 to 18;
if(t mod 4==0)
rx=rand(-20,20);
rz=rand(-20,20);

col=col0+rand(0,3);
x1=obj[tank[index]].vertex[v1].x+rx;
y1=obj[tank[index]].vertex[v1].y+rand(0,10);
z1=obj[tank[index]].vertex[v1].z+rz;
x2=x1-2*rx;
y2=obj[tank[index]].vertex[v2].y+rand(0,10);
z2=z1-2*rz;
x3=x1+rand(-10,10);
z3=z1+rand(-10,10);
y3=y1+rand(40,80);
flame2(x1,y1,z1,x2,y2,z2,x3,y3,z3,170+rand(-5,5),rand(6,10));
end
end
frame;
t+=1;
col-=1;
end

end


//___________________________________________________________________________________

process manfire(index)
private
col;

begin
col=170;
ctype=c_scroll;
graph=107;
player_id[index].state=onfire;
from c=0 to 60;
x=obj[player[index]].posx;
y=obj[player[index]].posz;
angle=obj[player[index]].angley+rand(-30000,30000);
if(c mod 2==0)
flame(x,y,rand(30,50),col,30,3);
state+=1;
end
frame;
end

while(state>0 and c<1000)
angle=obj[player[index]].angley+rand(-30000,30000);
x=obj[player[index]].posx;
y=obj[player[index]].posz;
c+=1;
frame;
end

end

//___________________________________________________________________________________


process oilfire(x,y,patch_id);
private
col;
n;
begin
col=164;
ctype=c_scroll;
graph=107;
from c=0 to 1000 step 80;
//col-=3;
if(c<=150)
flame(x,y,0,col,100,40);
end
frame;
end
from c=0 to 60;
frame;
end
if(patch_id<>0)
patch_id.renderme-=1;
end
end

//___________________________________________________________________________________
process igniteoil(x,y,patch_id);
private
x0;
y0;
begin
ctype=c_scroll;
graph=102;
x0=x; y0=y;
if(collision(type oilpatch) and not collision(type oilfire))
oilfire(x,y,patch_id);
patch_id.state+=1;
patch_id.renderme+=1;
frame;
END
x=x0+200;
if(collision(type oilpatch) and not collision(type oilfire))
igniteoil(x,y,patch_id);
frame;
END
x=x0-200;
if(collision(type oilpatch) and not collision(type oilfire))
igniteoil(x,y,patch_id);
frame;
END
x=x0;
y=y0+200;
if(collision(type oilpatch) and not collision(type oilfire))
igniteoil(x,y,patch_id);
frame;
END
y=y0-200;
if(collision(type oilpatch) and not collision(type oilfire))
igniteoil(x,y,patch_id);
frame;
END

end



//___________________________________________________________________________________

process spark(x,y,z);
private
    travel;  x0; y0: z0; x1;y1; z1; velh;  velv; velx; velz;  col=64; vel; col0;
begin
    x0=x;
    y0=y;
    if(y0<0)
        y0=1;
    END
    z0=z;
    x1=x0; y1=y0; z1=z0;
    angle=rand(0,360000);
    vel=rand(10,20);
    velv=-get_disty(angle,vel);
    velh=get_distx(angle,vel);
    angle=rand(0,360000);
    col=cyan-rand(0,10);
    col0=cyan0;
    while(travel<4)
            x1+=get_distx(angle,velh);
            y1+=velv;
            if(y1<0)
                break;
            END
            z1+=get_disty(angle,velh);
            if(y1>=0)
                tracer(x0,y0,z0,x1,y1,z1,col,col0,10);
            END
            x0=x1; y0=y1; z0=z1;
        frame;
        travel+=1;
    END

end


process laserdot(x,y,z,col);
private
    travel;  x0; y0: z0; x1;y1; z1; velh;  velv; velx; velz;   vel; col0;
begin
    x0=x;
    y0=y;
    if(y0<0)
        y0=1;
    END
    z0=z;
    x1=x0; y1=y0; z1=z0;
    angle=rand(0,360000);
    vel=4;
    velv=-get_disty(angle,vel);
    velh=get_distx(angle,vel);
    angle=rand(0,360000);
    col0=128;
            x1+=get_distx(angle,velh);
            y1+=velv;
            z1+=get_disty(angle,velh);
            if(y1>=0)
                tracer(x0,y0,z0,x1,y1,z1,col,col0,2);
            END
            x0=x1; y0=y1; z0=z1;
        frame;
end




//_________________________________________________________________________________________




// draw_3dline(x0,y0,z0,x1,y1,z1,1-index,index,cyan,cyan0,0);
process laser(n,objnum)
private
    travel; s;  x0; y0: z0; x1;y1; z1; velh;  velv; velx; velz; col,  vel; col0; steps; hit_box;
begin
    travel=0;
    steps=10;
    ctype=c_scroll;
    graph=100;
    x0=obj[body[n].arm_r].posx;
    y0=obj[body[n].arm_r].posy;
    if(y0<0)
        y0=1;
    END
    z0=obj[body[n].arm_r].posz;
    x1=x0; y1=y0; z1=z0;
    angle=obj[body[n].arm_r].anglex-90000;
    vel=100;
    velv=-get_disty(angle,vel);
    velh=get_distx(angle,vel);
    angle=obj[body[n].arm_r].angley+90000;
    col=cyan;
    col0=cyan0;
    while(travel<50)
        x1+=get_distx(angle,velh);
        y1+=velv;
        if(y1<0)
            y1=0;
        END
        z1+=get_disty(angle,velh);

        for(c=1; c<=steps; c+=1)
            x=x0+c*(x1-x0)/steps;
            z=y0+c*(y1-y0)/steps;
            y=z0+c*(z1-z0)/steps;

            if(z<=0)
              laserdot(x,z,y,150-travel/5);
                    signal(id,s_kill);
                    frame;

            end

            hit_box=(collision(type box));
            if(hit_box)
                if(hit_box.height>z/2)
                     laserdot(x,z,y,150-travel/5);
                    signal(id,s_kill);
                    frame;
                END
            END

            if(travel>0)
            hit_box=(collision(type tankobj));
            if(hit_box)
                if(z<100 and(hit_box.state==onfoot or hit_box.state==action))
                     laserdot(x,z,y,150-travel/5);
                    signal(id,s_kill);
                    frame;
                END
            END

            hit_box=(collision(type player_obj));
            if(hit_box)
                if(hit_box==player_id[1-n])
                    if (hit_box.state==onfoot or hit_box.state==got_shell or hit_box.state==got_fuel or hit_box.state==kamikazi)
                        if(z<60)
                            laserdot(x,z,y,150-travel/5);
                            signal(id,s_kill);
                            frame;
                        END
                    END
                END
            END

            hit_box=(collision(type pwrup));
            if(hit_box)
                if(z<60)
                     laserdot(x,z,y,150-travel/5);
                    signal(id,s_kill);
                    frame;
                END
            END



            END


        END
        x0=x1; y0=y1; z0=z1;
        travel+=1;
    END
    frame;
end


process  reload(objnum,index,priority)

begin
    while(key(fire[index]) and score.bullets[index]<6)
        c+=1;
        if(c==10)
            score.bullets[index]+=1;
            c=0;
        end
        if(c mod 10 <3)
            move_objy(objnum,-5);
        end

        move_objy(objnum,8);

        rotate_objxyz(objnum,90000,0,0);
        frame;
    end

end



process bullet(n,objnum)
private
    travel; s;  x0; y0: z0; x1;y1; z1; velh;  velv; velx; velz; col,  vel; col0; steps; hit_box;
begin
    travel=0;
    steps=10;
    ctype=c_scroll;
    graph=100;
    x0=obj[body[n].arm_r].posx;
    y0=obj[body[n].arm_r].posy;
    if(y0<0)
        y0=1;
    END
    z0=obj[body[n].arm_r].posz;
    x1=x0; y1=y0; z1=z0;
    angle=obj[body[n].arm_r].anglex-90000;
    vel=100;
    velv=-get_disty(angle,vel);
    velh=get_distx(angle,vel);
    angle=obj[body[n].arm_r].angley+90000;
    col=64;
    col0=0;
    while(travel<50)
        x1+=get_distx(angle,velh);
        y1+=velv;
        z1+=get_disty(angle,velh);

        for(c=1; c<=steps; c+=1)
            x=x0+c*(x1-x0)/steps;
            z=y0+c*(y1-y0)/steps;
            y=z0+c*(z1-z0)/steps;


            if(z<=0)
                    for(s=0; s<4; s+=1)
                     spark(x,z,y);
                    END
                    hit_box=collision(type oilpatch);
                    if(hit_box)
                        igniteoil(x,y,hit_box);
                    END

                    signal(id,s_kill);
                    frame;

            end


            hit_box=(collision(type box));
            if(hit_box)
                if(hit_box.height>z/2)
                    for(s=0; s<4; s+=1)
                     spark(x,z,y);
                    END
                    signal(id,s_kill);
                    frame;
                END
            END

            hit_box=(collision(type player_obj));
            if(hit_box and hit_box<>player_id[n])
                if(z<60)
                    for(s=0; s<4; s+=1)
                     spark(x,z,y);
                    END
                    if(hit_box.state==onfoot or hit_box.state==hopping)
                        hit_box.state=shot;

                    else
                        if(hit_box.state==kamikazi  or hit_box.state==got_shell)
                        hit_box.state=boom;
                        else
                            if(hit_box.state==got_fuel)
                                manfire(1-n);

                                //hit_box.state=boom;
                            end
                        end
                    end
                    signal(id,s_kill);
                    frame;
                END
            END

            hit_box=(collision(type tankobj));

            if(hit_box)
                if(z<100 and (hit_box.state==onfoot or hit_box.state==action))
                    for(s=0; s<4; s+=1)
                     spark(x,z,y);
                     //hit_box.state=shot;
                    END
                    signal(id,s_kill);
                    frame;

                END
            END

            hit_box=(collision(type pwrup));

            if(hit_box)
                if(z<100)
                    for(s=0; s<4; s+=1)
                     spark(x,z,y);
                    END
                    signal(id,s_kill);
                    frame;

                END
            END


        END

        if(y1>=0)
            tracer(x0,y0,z0,x1,y1,z1,col,col0,16);
        END
        x0=x1; y0=y1; z0=z1;
        frame;
        travel+=1;




    END
end

//_________________________________________________________________________________________

PROCESS castlight(x,y,z,i,r);
PRIVATE
    n,intensity; dis;
BEGIN
    for(n=0; n<obj_count; n+=1)
        if(obj[n].fogme==1)
            dis=fget_dist(x,z,obj[n].posx,obj[n].posz);
            if(dis<r)
                intensity=((r-dis)*i)/r;
                if(intensity>i)
                    intensity=i;
                END
                obj[n].light_col=intensity;
                defog(n,1);
                dim(n);
            END
        end
    END

END


//--------------------------------------------------------------------------------
process dim(n)
begin
    loop
        if(obj[n].light_col>0)
            obj[n].light_col-=2;
        ELSE
            obj[n].light_col=0;
            break;
        END
       frame:
    END
end




//---------------------------------------------------------------------------------------

PROCESS tracer(x0,y0,z0,x1,y1,z1,col,col0,speed);
BEGIN
    LOOP
        col-=speed;
        if(col<col0)
            col=col0;
        END
        draw_3dline(x0,y0,z0,x1,y1,z1,1,1,col,col0,0);
        FRAME;
        if(col==col0)
            break;
        END
    END
END

//---------------------------------------------------------------------------------------
PROCESS rotate_objxyz(n,angX, angy, angz)
PRIVATE
    i; tmp;
BEGIN
    obj[n].anglex+=angx;
    obj[n].angley+=angy;
    obj[n].anglez+=angz;
    for( i=1; i<=obj[n].vertex_count; i+=1)
        obj[n].vertex[i].y=get_distx(obj[n].anglex,obj[n].vertex[i].yl)
                        +get_disty(obj[n].anglex,obj[n].vertex[i].zl);
        obj[n].vertex[i].z=get_distx(obj[n].anglex,obj[n].vertex[i].zl)
                        -get_disty(obj[n].anglex,obj[n].vertex[i].yl);
        obj[n].vertex[i].x=obj[n].vertex[i].xl;
    END
    for( i=1; i<=obj[n].vertex_count; i+=1)
        tmp=get_distx(obj[n].angley,obj[n].vertex[i].x)
                        -get_disty(obj[n].angley,obj[n].vertex[i].z);
        obj[n].vertex[i].z=get_distx(obj[n].angley,obj[n].vertex[i].z)
                        +get_disty(obj[n].angley,obj[n].vertex[i].x);
        obj[n].vertex[i].x=tmp:
    END

    for( i=1; i<=obj[n].vertex_count; i+=1)
        obj[n].vertex[i].y+=obj[n].vertex[0].y;
        obj[n].vertex[i].x+=obj[n].vertex[0].x;
        obj[n].vertex[i].z+=obj[n].vertex[0].z;
    END
    if(obj[n].anglex>360000) obj[n].anglex-=360000; END
    if(obj[n].anglex<=0) obj[n].anglex+=360000; END
    if(obj[n].angley>360000) obj[n].angley-=360000; END
    if(obj[n].angley<=0) obj[n].angley+=360000; END
    if(obj[n].anglez>360000) obj[n].anglez-=360000; END
    if(obj[n].anglez<=0) obj[n].anglez+=360000; END
END

//--------------------------------------------------------------------------------

PROCESS rotate_objzyx(n,angX, angy, angz)
PRIVATE
    i; tmp;
BEGIN
    obj[n].anglex+=angx;
    obj[n].angley+=angy;
    obj[n].anglez+=angz;
    for( i=1; i<=obj[n].vertex_count; i+=1)
        obj[n].vertex[i].x=get_distx(obj[n].anglez,obj[n].vertex[i].xl)
                        +get_disty(obj[n].anglez,obj[n].vertex[i].yl);
        obj[n].vertex[i].y=get_distx(obj[n].anglez,obj[n].vertex[i].yl)
                        -get_disty(obj[n].anglez,obj[n].vertex[i].xl);
        obj[n].vertex[i].z=obj[n].vertex[i].zl;
    END
    for( i=1; i<=obj[n].vertex_count; i+=1)
        tmp=get_distx(obj[n].angley,obj[n].vertex[i].x)
                        -get_disty(obj[n].angley,obj[n].vertex[i].z);
        obj[n].vertex[i].z=get_distx(obj[n].angley,obj[n].vertex[i].z)
                        +get_disty(obj[n].angley,obj[n].vertex[i].x);
        obj[n].vertex[i].x=tmp:
    END
    for( i=1; i<=obj[n].vertex_count; i+=1)
        tmp=get_distx(obj[n].anglex,obj[n].vertex[i].y)
                        -get_disty(obj[n].anglex,obj[n].vertex[i].z);
        obj[n].vertex[i].z=get_distx(obj[n].anglex,obj[n].vertex[i].z)
                        +get_disty(obj[n].anglex,obj[n].vertex[i].y);
        obj[n].vertex[i].y=tmp:
    END
    for( i=1; i<=obj[n].vertex_count; i+=1)
        obj[n].vertex[i].y+=obj[n].vertex[0].y;
        obj[n].vertex[i].x+=obj[n].vertex[0].x;
        obj[n].vertex[i].z+=obj[n].vertex[0].z;
    END
    if(obj[n].anglex>360000) obj[n].anglex-=360000; END
    if(obj[n].anglex<=0) obj[n].anglex+=360000; END
    if(obj[n].angley>360000) obj[n].angley-=360000; END
    if(obj[n].angley<=0) obj[n].angley+=360000; END
    if(obj[n].anglez>360000) obj[n].anglez-=360000; END
    if(obj[n].anglez<=0) obj[n].anglez+=360000; END
END
//--------------------------------------------------------------------------------

PROCESS position_obj(n,posx,posy,posz)
private
    i;
BEGIN
    FOR(I=1; I<=obj[n].vertex_count; i+=1)
        obj[n].vertex[i].x+=posx-obj[n].vertex[0].x;
        obj[n].vertex[i].y+=posy-obj[n].vertex[0].y;
        obj[n].vertex[i].z+=posz-obj[n].vertex[0].z;
    END
    obj[n].vertex[0].x+=posx-obj[n].vertex[0].x;
    obj[n].vertex[0].y+=posy-obj[n].vertex[0].y;
    obj[n].vertex[0].z+=posz-obj[n].vertex[0].z;
    obj[n].posx=posx;
    obj[n].posy=posy;
    obj[n].posz=posz;
END

//--------------------------------------------------------------------------------

PROCESS move_objxz(n,vel)
PRIVATE
    i;
BEGIN
    obj[n].vel=vel;
    FOR(I=0; I<=obj[n].vertex_count; i+=1)
        obj[n].vertex[i].x+=get_disty(obj[n].angley,obj[n].vel);
        obj[n].vertex[i].z-=get_distx(obj[n].angley,obj[n].vel);
    END
    obj[n].posx=obj[n].vertex[0].x;
    obj[n].posy=obj[n].vertex[0].y;
    obj[n].posz=obj[n].vertex[0].z;
    FRAME;
END

//--------------------------------------------------------------------------------

PROCESS move_objy(n,vel)
PRIVATE
i;
BEGIN
    obj[n].vely=vel;
    FOR(I=0; I<=obj[n].vertex_count; i+=1)
        obj[n].vertex[i].y+=obj[n].vely;
    END
    obj[n].posx=obj[n].vertex.x;
    obj[n].posy=obj[n].vertex.y;
    obj[n].posz=obj[n].vertex.z;
END

//--------------------------------------------------------------------------------

PROCESS set_tank_state(n,state)
BEGIN
    hull_id[n].state=state;
    turret_id[n].state=state;
    barrel_id[n].state=state;
    shaft_id[n].state=state;
    dish_id[n].state=state;
    tank_id[n].state=state;
    post_id[n].state=state;
    if(state==action)
        huds_id[n].state=0;
    else
        huds_id[n].state=1;
    end
END
//--------------------------------------------------------------------------------
PROCESS crack_screen(n);
PRIVATE
    d; t; cracks; col0;
    STRUCT CRACK[15]
        x0,y0,dx,dy;, t0; t1;x1,y1; ang;    xt; yt;
    end
BEGIN
    x=cam[n].cx+rand(-100,100);
    y=cam[n].cy+rand(-25,25);

    for(c=0; c<4; c+=1)
        crack[c].x0=x;
        crack[c].y0=y;
        crack[c].xt=x;
        crack[c].yt=y;
        crack[c].ang=(180000*(c/2))-30000+45000*(c mod 2)+rand(-15000,15000);
        crack[c].t0=0;
        crack[c].t1=60+rand(80,120);
        draw(1,80,15,1+n,crack[c].x0,crack[c].y0,crack[c].x0,crack[c].y0);
        crack[c].x1=crack[c].x0+get_distx(crack[c].ang,crack[c].t1);
        crack[c].y1=crack[c].y0+get_disty(crack[c].ang,crack[c].t1);
        crack[c+4].x0=crack[c].x1;
        crack[c+4].y0=crack[c].y1;
        crack[c+4].xt=crack[c+4].x0;
        crack[c+4].yt=crack[c+4].y0;
        crack[c+4].ang=crack[c].ang+rand(-40000,-10000);
        crack[c+4].t0=crack[c].t1;
        crack[c+4].t1=crack[c+4].t0+rand(180,220);
        crack[c+4].x1=crack[c+4].x0+get_distx(crack[c+4].ang,crack[c+4].t1-crack[c+4].t0);
        crack[c+4].y1=crack[c+4].y0+get_disty(crack[c+4].ang,crack[c+4].t1-crack[c+4].t0);
        draw(1,80,15,1+n,crack[c].x0,crack[c].y0,crack[c].x0,crack[c].y0);
        crack[c+8].x0=crack[c].x1;
        crack[c+8].y0=crack[c].y1;
        crack[c+8].xt=crack[c+8].x0;
        crack[c+8].yt=crack[c+8].y0;
        crack[c+8].ang=crack[c].ang+rand(10000,40000);
        crack[c+8].t0=crack[c+8].t1;
        crack[c+8].t1=crack[c+4].t0+rand(180,220);
        crack[c+8].x1=crack[c+8].x0+get_distx(crack[c+8].ang,crack[c+8].t1-crack[c+8].t0);
        crack[c+8].y1=crack[c+8].y0+get_disty(crack[c+8].ang,crack[c+8].t1-crack[c+8].t0);
        draw(1,80,15,1+n,crack[c].x0,crack[c].y0,crack[c].x0,crack[c].y0);
    END
    col0=64;
    while(t<40)
        IF(T<2) draw(3,63,15,n+1,0,0,scr_w,scr_h); END
        if(t<8)
        cam[n].posx+=rand(-200,200);
        cam[n].posz+=rand(-200,200);
        cam[n].angle=rand(-3000,3000);
        END

        col0+=4;
        for(c=0; c<12; c+=1)
            if(t>crack[c].t1)
                crack[c].xt=crack[c].x1;
                crack[c].yt=crack[c].y1;
            ELSE
                if(t>crack[c].t0)
                    crack[c].xt=crack[c].x0+get_distx(crack[c].ang,t*40-crack[c].t0);
                    crack[c].yt=crack[c].y0+get_disty(crack[c].ang,t*40-crack[c].t0);
                 END
            END
            draw(1,col0,5,1+n,crack[c].x0,crack[c].y0,crack[c].xt,crack[c].yt);
        END

        t+=1;
        FRAME;
    end
    t=0;
    WHILE(t<20)
        t+=1;
        cam[n].fog-=4;
        if(cam[n].fog<=0)
            cam[n].fog=1;
        END
        FRAME;
    END
END
//--------------------------------------------------------------------------------

PROCESS tankobj(index,n,verts,edges,faces,x0,y0,z0,ang0,col)
PRIVATE
    i; n;  velx; velz; tilt; twist; vel;   vely;  rolling_sound=16;
    tilting_sound=16;  twisting_Sound=16;  twistspeed;  radi;  timeout; time0; ang;
    angT; eject;  tcol;   temp;  cooling;   flicker;

    struct old
        x,z,ang;
    end

BEGIN
    //state=out;
    flags=4;
    if(n==0)
        scroll.camera=id;
    END
    graph=ctank_graph[n];
    ctype=c_scroll;
    n=index;
    obj[index].angley=ang0;
    position_obj(n,x0,y0,z0);
    x=obj[n].posx;
    y=obj[n].posz;
    angle=obj[n].angley;
    frame;
    renderme=draw_objf(n,1,1);
    state=ready;
    huds_id[n]=huds(n,cam[n].cx,cam[n].cy);

    LOOP



        old.x=obj[n].posx;
        old.z=obj[n].posz;
        old.ang=obj[n].angley;

        tilt=0; twist=0;
        //vel=0;
        write_int(0,100,100*n,0,&temp);

        if((state==onfoot or state==action) and collision(type oilfire))
           temp+=2;
        end

        if(temp>0)
          cooling+=1;
          obj[tank[n]].fogme=0;
          if(cooling mod 4==0)
          temp-=1;
          cooling=0;
          end
          if(state==action or state==onfoot)
            if(temp<=10)
                obj[tank[n]].col0=240+temp;
            else

                tankfire(n);
                state=onfire;
                temp=16;
                cooling=0;
            END
          end
        end



        if(temp<=0 and (state==action or state==onfoot) and obj[tank[n]].col0>green)
        obj[tank[n]].fogme=1;
        obj[tank[n]].col0=green;
        END

       /*
        if(key(_space) and n==0)
        if(tank_id[0].state==action)
        TEMP=12;
        END
        end
       */


        switch(state)
            case ready:
               state=respawn;
            END
            case respawn:
                repeat

                    ang=45000*rand(0,7);
                    obj[tank[n]].angley=(ang+90000) mod 360000;
                    obj[tank[n]].anglex=0;
                    obj[n].posx=get_distx(ang,9000);
                    obj[n].posy=y0;
                    obj[n].posz=get_disty(ang,9000);
                    obj[n].posx=0;
                    obj[n].posz=(1000*n);
                    obj[tank[n]].col0=green;
                    obj[tank[n]].fogme=1;

                    x=obj[n].posx;
                    y=obj[n].posz;
                until( not collision(type tankobj))
                set_tank_state(n,show);
                score.shells[n]=score.ammo0;
                score.fuel[n]=score.fuel0;
                position_obj(tank[n],obj[n].posx,obj[n].posy,obj[n].posz);
                rotate_objxyz(tank[n],0,0,0);
            END
            case show:
                while(cam[n].fog<fog)
                    cam[n].fog+=10;
                    frame;
                END
                hopin(n);
                set_tank_state(n,action);
                //player_id[n].state=action;
                hide_tank(n,0,1-n);
                hide_tank(n,1,n);
                im_id[tank[1-n]].state=respawn;
                //signal(huds_id[index],s_wakeup_tree);
                huds_id[index].state=0;

            END
            case boom:
                set_tank_state(n,exploding);
                sound(snd_exp,256,256);
                vely=33;
                if(player_id[n].state==action)
                    crack_screen(n);
                    player_id[n].state=dead;
                    END

                //signal(huds_id[index],s_sleep_tree);
                //obj[tank[n]].fogme=0;

                huds_id[index].state=1;

                im_id[1-n].state=boom;
            END

            case exploding;
                if(obj[n].posy>-1)
                    move_objy(n,vely);
                    vely-=2;
                    rotate_objxyz(n,5000,0,0);
                    //obj[tank[n]].fogme=0;

                    if(temp>0)
                        obj[tank[n]].col0=240+temp;
                    end
                else

                state=dead;
                obj[tank[n]].fogme=1;
                obj[tank[n]].col0=green;

                temp=0;
                END

            END

            case shot:
            obj[tank[n]].fogme=0;

                if(flicker<64)
                    flicker+=1;
                    flickerout(tank[n],flicker);

                else
                    set_tank_state(n,respawn);
                    flicker=0;
                end
            END
            case onfire:
                  temp+=2;
                obj[tank[n]].col0=128+temp;
                if(temp>40)
                set_tank_state(n,boom);
                temp=10;
                if(player_id[n].state==action)
                    player_id[n].state=dead;
                    END

                end

            end

            case dead:
               if(hull_id[n].state==dead
                   and turret_id[n].state==dead
                   and barrel_id[n].state==dead
                   and dish_id[n].state==dead
                   and post_id[n].state==dead
                   and shaft_id[n].state==dead
                   )

                        if(flicker<64)
                            flicker+=1;
                            flickerout(tank[n],flicker);
                        else
                            hide_tank(n,1,n);
                            hide_tank(n,1,1-n);
                            if(player_id[n].state==dead)
                                set_tank_state(n,respawn);
                            end
                        end
                else
                flicker=0;
                END
            END



            case onfoot;
                if(player_id[n].state==action)
                    set_tank_state(n,action);
                END
                if(player_id[n].state==dead)
                    state=shot;
                end

            END

//action commands......................................................................
            case action:


                    if(key(lf[n]) and key(rt[n]) and eject==0)
                        time0=timer;
                        eject=1;
                    end
                    if(eject==1)
                        timeout=(timer-time0);

                        if(timeout<=160)
                                 i+=1;
                                //vwrite(cam[n].cx-40,cam[n].cy-40,120,146,"eject");


                                if(timeout<=100)

                                    for(c=0; c<32; c+=8)
                                        if(c<=(timeout-20)/2)
                                            tcol=red;
                                        else
                                            tcol=green0+32;
                                        end

                                    draw(1,tcol,15,0,cam[n].cx-60,cam[n].cy+90-c,cam[n].cx-52,cam[n].cy+90-c);
                                    draw(1,tcol,15,0,cam[n].cx-60,cam[n].cy+90-c,cam[n].cx-56,cam[n].cy+85-c);
                                    draw(1,tcol,15,0,cam[n].cx-52,cam[n].cy+90-c,cam[n].cx-56,cam[n].cy+85-c);

                                    end
                                    vwrite(cam[n].cx-70,cam[n].cy+50,40,green0+32,"eject");

                                 else
                                    tcol=130+16*((i/2) mod 2);
                                vwrite(cam[n].cx-70,cam[n].cy+50,40,245+rand(0,5),"eject");

                                end

                        else
                            hopout(n);
                            eject=0;

                        end
                    END

                    if(eject==2)
                        if(not (key(lf[n]) and key(rt[n])))
                            eject=0;
                        end
                    end


                    if(eject==0)
                                    for(c=0; c<32; c+=8)
                                            tcol=green0+16;
                                    draw(1,tcol,15,0,cam[n].cx-60,cam[n].cy+90-c,cam[n].cx-52,cam[n].cy+90-c);
                                    draw(1,tcol,15,0,cam[n].cx-60,cam[n].cy+90-c,cam[n].cx-56,cam[n].cy+85-c);
                                    draw(1,tcol,15,0,cam[n].cx-52,cam[n].cy+90-c,cam[n].cx-56,cam[n].cy+85-c);

                                    end

                                vwrite(cam[n].cx-70,cam[n].cy+50,40,tcol-8,"eject");

                    end



                    if(key(up[n]) xor key(dn[n]))
                        if(key(ctrl[n]) )
                            tilt=(key(up[n])-key(dn[n]))*100;
                        ELSE
                            if(score.fuel[n]>=30)
                                if(abs(vel)<30)
                                    vel+=(key(up[n])-key(dn[n]))*2;
                                    if( not is_playing_sound(rolling_sound))
                                        rolling_sound=sound(snd_rolling,256,256);
                                    END
                                END
                                score.fuel[n]-=abs(vel)/2;
                            END
                        END
                    ELSE
                        if(is_playing_sound(rolling_sound))
                            stop_sound(rolling_sound);
                            rolling_sound=16;
                        END


                        if(abs(vel)>0)
                           vel=vel*8/10;
                        END
                    END





                move_objxz(n,vel);
                radi=abs(fget_dist(0,0,obj[n].posx,obj[n].posz));
                WHILE(radi>15000)
                    move_objxz(n,-vel);
                    x=obj[n].posx;
                    y=obj[n].posz;
                    radi=abs(fget_dist(0,0,obj[n].posx,obj[n].posz));
                    vwrite(cam[n].cx-50,cam[n].cy-20,200,red+rand(0,4),"halt");
                    FRAME;
                END
                x=obj[n].posx;
                y=obj[n].posz;
                WHILE(collision(type box) or collision(type tankobj))
                    move_objxz(n,-vel);
                    x=obj[n].posx;
                    y=obj[n].posz;
                END
                if(tilt<>0 AND shaft_id[index].angle>0 AND shaft_id[index].angle<10000)
                    if( not is_playing_sound(tilting_sound))
                        tilting_sound=sound(snd_tilting,64,512);
                    END
                ELSE
                    if(is_playing_sound(tilting_sound))
                        stop_sound(tilting_sound);
                        tilting_sound=16;
                    END
                END
                shaft_id[index].angle+=tilt;
                if(shaft_id[index].angle<0)
                    shaft_id[index].angle=0;
                ELSE
                    if(shaft_id[index].angle>10000)
                        shaft_id[index].angle=10000;
                    end

                END


                if(key(ctrl[n]))
                    if(abs(twistspeed)<5000)
                        twistspeed+=100*(key(lf[n])-key(rt[n]));

                    END
                    twist=twistspeed;
                    if(key(lf[n])-key(rt[n])==0)
                        twistspeed=0;
                    END
                    turret_id[index].angle=(turret_id[index].angle+twist) % 360000;
                    //turret_id[index].angle+=twist;

                ELSE
                    if(abs(ang)<3000)
                        ang+= (key(lf[n])-key(rt[n]))*300;
                    END


                    if(((key(lf[n]) - key(rt[n]))*ang<0 or key(lf[n]) + key(rt[n])==0) and abs(ang)>0)
                          ang=ang/2;
                    END

                    if(key(lf[n]) and key(rt[n]))
                        if(abs(turret_id[index].angle)>3000)

                            if(turret_id[index].angle>0)
                                ang=+3000;
                                turret_id[index].angle-=3000;
                            ELSE
                                if(turret_id[index].angle<0)
                                    ang=-3000;
                                    turret_id[index].angle+=3000;
                                END
                           END
                        ELSE
                            turret_id[index].angle=turret_id[index].angle/2;
                            ang=turret_id[index].angle;

                      END
                    END

                        twistspeed=0;
                        rotate_objxyz(index,0,ang,0);
                        angle=obj[n].angley;
                        IF(collision(type box)or collision(type tankobj))
                            rotate_objxyz(index,0,-(ang),0);
                            angle=obj[n].angley;
                        END

                END
                if(twist<>0)
                    if( not is_playing_sound(twisting_sound))
                        twisting_sound=sound(snd_twisting,64,256);
                    END
                ELSE
                    if(is_playing_sound(twisting_sound))
                        stop_sound(twisting_sound);
                        twisting_sound=16;
                    END
                END
                if(Collision(type box) or collision(type tankobj))
                    position_obj(n,old.x,obj[n].posy,old.z);
                    rotate_objxyz(n,0,old.ang,0);
                END
            END
            default:

            END
        END
            if(state<> action)
                    if(is_playing_sound(twisting_sound))
                        stop_sound(twisting_sound);
                        twisting_sound=16;
                    END
                    if(is_playing_sound(tilting_sound))
                        stop_sound(tilting_sound);
                        tilting_sound=16;
                    END
                    if(is_playing_sound(rolling_sound))
                        stop_sound(rolling_sound);
                        rolling_sound=16;
                    END
            END

        FRAME;
    END
END

//--------------------------------------------------------------------------------
PROCESS tank_part(objNum,verts,edges,faces,x0,y0,z0,ang,n,part,parent,fix,col,graph0)
private
    i; turret_angle; shaft_angle;  velxz; vely;  vel;   velx; velz;
    roty,rotz, rotx;  pitch; dir; flicker;
BEGIN
    ctype=c_scroll;
    FOR(i=0; i<=verts; i+=1)
        obj[objNum].vertex[i].x+=x0;
        obj[objNum].vertex[i].y+=y0;
        obj[objNum].vertex[i].z+=z0;
    END
    if(objnum<>shaft[n])
       renderme=draw_objf(objnum,1,1);
       renderme.renderme=n+1;
    end
    priority=tank_id[n].priority-1;
    LOOP
        obj[objnum].light_col=obj[tank[n]].light_col;
        obj[objnum].col0=obj[tank[n]].col0;
        obj[objnum].fogme=obj[tank[n]].fogme;
        switch(state)

            case reset,respawn,show:
                obj[objnum].angley=obj[parent].angley;
                obj[objnum].anglex=obj[parent].anglex;
                position_obj(objNum,obj[parent].vertex[fix].x,obj[parent].vertex[fix].y,obj[parent].vertex[fix].z);
                rotate_objxyz(objNum,0,0,0);
                frame;
            END

            case action;
                obj[objnum].angley=obj[parent].angley;
                obj[objnum].anglex=obj[parent].anglex;
                position_obj(objNum,obj[parent].vertex[fix].x,obj[parent].vertex[fix].y,obj[parent].vertex[fix].z);
                rotate_objxyz(objNum,0,0,0);
                switch (id)
                    case hull_id[n];
                        angle=obj[parent].angley;
                    END
                    case turret_id[n];
                        rotate_objxyz(objNum,0,angle,0);
                        angle=(angle) mod 360000;
                    END
                    case shaft_id[n];
                        if(angle>10000)
                            angle=10000;
                        END
                        if(angle<0)
                            angle=0;
                        END
                        rotate_objxyz(objNum,angle,0,0);
                    END
                    case barrel_id[n];
                    END
                    case dish_id[n];
                        angle=(angle-9000) mod 360000;
                        rotate_objxyz(objNum,0,angle,0);
                    END
                    default; end
                END
            END
            case exploding:
                obj[objnum].angley=obj[parent].angley;
                obj[objnum].anglex=obj[parent].anglex;
                position_obj(objNum,obj[parent].vertex[fix].x,obj[parent].vertex[fix].y+1,obj[parent].vertex[fix].z);
                vel=rand(50,100);
                dir=rand(0,360000);
                pitch=rand(5000,40000);
                rotx=rand(-20000,20000);
                roty=rand(-20000,20000);
                rotz=rand(-20000,20000);
                vely=-get_disty(pitch,vel);
                velxz=get_distx(pitch,vel);
                velx=get_distx(dir,velxz);
                velz=get_distx(dir,velxz);
                while(obj[objnum].posy>-1)
                    obj[objnum].posx+=velx;
                    obj[objnum].posy+=vely;
                    obj[objnum].posz+=velz;
                    position_obj(objNum,obj[objnum].posx,obj[objnum].posy,obj[objnum].posz);
                    rotate_objxyz(objnum,rotx,roty,0);
                    vely-=1;
                    obj[objnum].col0=obj[parent].col0;
                    obj[objnum].fogme=obj[parent].fogme;

                    frame;
                END
                state=dead;
            END
            case dead:

            END
            default:
            END
        END
        FRAME;
    END
END
//-------------------------------------------------------------------------------

PROCESS box(objNum,w,d,h,verts,edges,faces,x0,h,z0,ang,col)

BEGIN
    position_obj(objNum,x0,h,z0);
    rotate_objxyz(objNum,0,ang,0);
    renderme=draw_objf(objNum,1,1);
    height=h;
    ctype=c_scroll;
    graph=new_map(2*w,2*d,w,d,240);
    x=obj[objnum].posx;
    y=obj[objnum].posz;
    z=height;
    angle=obj[objnum].angley;

    LOOP
        FRAME;
    END
END

//--------------------------------------------------------------------------------
process flickerout(objnum,flicker)
begin
    obj[objnum].fogme=0;
    obj[objnum].col0=color[flicker mod 3]-flicker;
    if(obj[objnum].col0<=green0)
        obj[objnum].col0=green0;
    end
end

//--------------------------------------------------------------------------------

PROCESS player_obj(index,objNum,w,d,h,verts,edges,faces,x0,h,z0,ang,col,part)
private
    vel; ang; radi; px; pz; py; cosA; sinA; c_id; dx, dy; A1;
    theta; swing;    fired;  switching;   aim1; aim2, flicker,
    x0; y0; z0; x1; y1; z1;   i:
    dir, pitch, velx, vely, velxz, velz, rotx,roty,rotz;   launchvel;

BEGIN
    h=32;
    position_obj(objNum,x0,1000,z0);
    rotate_objxyz(objNum,0,ang,0);
    renderme=draw_objf(objNum,1,1);
    height=h;
    if(part==0)
        ctype=c_scroll;
        graph=new_map(2*w,2*d,w,d,240);
        x=obj[objnum].posx;
        y=obj[objnum].posz;
        z=obj[objnum].posy;
        angle=obj[objnum].angley;
        if(player_id[index]==0) player_id[index]=id; END
    end
    LOOP


        if(player_id[index].state==kamikazi)
            obj[objnum].anglex=90000;
        ELSE
            obj[objnum].anglex=3600000;
        END




        if (player_id[index]==id)


                switch(state)
                    case action:
                    launchvel=32;
                    if(tank_id[index].state==exploding) state=dead; END
                    end


                    case kamikazi:
                        if(i<200)
                            if(vel<160)
                                if(vel==0)
                                    vely=24;
                                    i=0;
                                end
                                vel+=10;
                            end

                        else vel=99*vel/100;
                        end


                        if(key(lf[index]) and ang<5000)
                        ang+=100;
                        end
                        if(key(rt[index]) and ang>-5000)
                        ang-=100;
                        end
                        if(not key(lf[index]) and not key(rt[index]))
                          ang=4*ang/5;
                        END
                        i+=1;
                        rotate_objxyz(player[index],0,ang,0);

                        angle=obj[player[index]].angley;

                            velx=get_disty(angle,vel);
                            velz=-get_distx(angle,vel);

                            if(not key(up[index]) or vely>=0 or i>200) vely-=1;  end
                            if(key(dn[index])) vely-=1; end

                        obj[objnum].posx+=velx;
                        obj[objnum].posz+=velz;
                        obj[objnum].posy+=vely;

                        position_obj(objnum,obj[objnum].posx,obj[objnum].posy,obj[objnum].posz);


                        x=obj[objnum].posx;
                        y=obj[objnum].posz;

                        c_id=collision(type box);
                        if(c_id)
                            if(obj[objnum].posy<c_id.height)
                                move_objxz(objnum,-vel);
                                x=obj[objnum].posx;
                                y=obj[objnum].posz;
                                state=boom;
                            end
                        END

                        if(obj[objnum].posy<200)
                            if(obj[objnum].posy<=0)
                               obj[objnum].posy=0;
                               state=boom;
                               explosionF(obj[objnum].posx,obj[objnum].posy,obj[objnum].posz,8,cyan0,cyan);

                            end
                            c_id=collision(type tankobj);
                            if(c_id)
                                if(c_id.state==action or c_id.state==onfoot)
                                    move_objxz(objnum,-vel);
                                    x=obj[objnum].posx;
                                    y=obj[objnum].posz;
                                    state=boom;
                                    c_id.state=boom;
                                end
                            end
                        END

                        x0=obj[s_minishell[index].part[0]].posx;
                        y0=obj[s_minishell[index].part[0]].posy;
                        z0=obj[s_minishell[index].part[0]].posz;



                        s_minishell[index].part_id[0].priority=priority-1;
                        s_minishell[index].part_id[1].priority=priority-2;
                        angle=obj[player[index]].angley-90000;
                        obj[s_minishell[index].part[0]].angley=angle;

                        obj[s_minishell[index].part[0]].posx=obj[objnum].posx+get_distx(angle,20);
                        obj[s_minishell[index].part[0]].posy=obj[objnum].posy+20;
                        obj[s_minishell[index].part[0]].posz=obj[objnum].posz+get_disty(angle,20);
                        obj[s_minishell[index].part[0]].anglex=90000;
                        obj[s_minishell[index].part[0]].angley-=90000;


                        x1=obj[s_minishell[index].part[0]].posx;
                        y1=obj[s_minishell[index].part[0]].posy;
                        z1=obj[s_minishell[index].part[0]].posz;

                        if(i<200)
                        for(c=0; c<=4; c+=1)
                            tracer(x0+rand(-2,2),y0+rand(-2,2),z0+rand(-2,2),
                            x1+rand(-6,6),y1+rand(-6,6),z1+rand(-6,6),fire0+rand(32,48),fire0,8);
                        end
                        end
                    END


                    case hopping:
                       if(obj[objnum].posy>height)
                        launchvel-=4;
                        move_objy(objnum,launchvel);

                        vel=15;
                        move_objxz(objnum,vel);
                        else
                         obj[objnum].posy=height;
                         position_obj(objnum,obj[objnum].posx,obj[objnum].posy,obj[objnum].posz);
                         state=onfoot;

                        END
                    END

                    case onfoot,got_fuel, onfire, got_shell:
                            vel=(key(up[index])-key(dn[index]))*15;

                        if(key(ctrl[index]))
                            if( switching==0)
                                stopnshoot[index]=1-stopnshoot[index];
                            END
                            switching=1;
                        else
                            switching=0;
                        END

                        if(stopnshoot[index]==1) vel=0; END
                        move_objxz(objnum,vel);
                        radi=abs(fget_dist(0,0,obj[index].posx,obj[index].posz));
                        WHILE(radi>15000)
                            move_objxz(objnum,-vel);
                            x=obj[objnum].posx;
                            y=obj[objnum].posz;
                            radi=abs(fget_dist(0,0,obj[player[index]].posx,obj[player[index]].posz));
                            vwrite(cam[index].cx-50,cam[index].cy-20,200,red+rand(0,4),"halt");
                            frame;
                        END
                        x=obj[objnum].posx;
                        y=obj[objnum].posz;
                        WHILE(collision(type box))
                            move_objxz(objnum,-vel);
                            x=obj[objnum].posx;
                            y=obj[objnum].posz;
                        END
                        repeat
                            c_id= collision(type tankobj);
                            if(c_id==tank_id[index])
                                if(c_id.state==onfoot)
                                    hopin(index);
                                END
                            else
                                if(c_id==tank_id[1-index])
                                    if(c_id.state==action or c_id.state==onfoot)
                                        move_objxz(objnum,-vel);
                                        x=obj[objnum].posx;
                                        y=obj[objnum].posz;
                                     end
                                end
                            END
                        until (c_id==0)
                        if(stopnshoot[index]==0)
                            //ang= (key(lf[index])-key(rt[index]))*5000;
                            if(key(lf[index]) and ang<5000)
                                ang+=500;
                            end
                            if(key(rt[index]) and ang>-5000)
                                ang-=500;
                            end
                            if(not key(lf[index]) and not key(rt[index]))
                                ang=ang/2;
                            END


                            rotate_objxyz(player[index],0,ang,0);
                            angle=obj[player[index]].angley;

                            IF(collision(type box) or collision(type tankobj))
                                rotate_objxyz(player[index],0,-(ang),0);
                                angle=obj[player[index]].angley;
                            END

                            x=obj[objnum].posx;
                            y=obj[objnum].posz;
                            z=height;
                            angle=obj[objnum].angley;

                        END


                        if(state==got_fuel)
                            s_minifuel[index].part_id[0].priority=priority-1;
                            s_minifuel[index].part_id[1].priority=priority-2;
                            angle=obj[player[index]].angley-90000;
                            sinA=sin(angle);
                            cosA=cos(angle);
                            obj[s_minifuel[index].part[0]].posx=obj[objnum].posx+cosA*20/1000;
                            obj[s_minifuel[index].part[0]].posy=obj[objnum].posy-10;
                            obj[s_minifuel[index].part[0]].posz=obj[objnum].posz-sinA*20/1000;
                            obj[s_minifuel[index].part[0]].angley=angle;
                            flicker=0;
                        END

                        if(state==got_shell)
                            s_minishell[index].part_id[0].priority=priority-1;
                            s_minishell[index].part_id[1].priority=priority-2;
                            angle=obj[player[index]].angley-90000;
                            obj[s_minishell[index].part[0]].angley=angle;


                            obj[s_minishell[index].part[0]].posx=obj[objnum].posx+get_distx(angle,20);
                            obj[s_minishell[index].part[0]].posy=obj[objnum].posy-10;
                            obj[s_minishell[index].part[0]].posz=obj[objnum].posz+get_disty(angle,20);
                            obj[s_minishell[index].part[0]].anglex=0;


                        END
                        if(state==onfoot or state==onfire)
                            s_minishell[index].part_id[0].state=out;
                            s_minifuel[index].part_id[0].state=out;

                            if(state==onfire)

                                obj[objnum].fogme=0;
                              switch(flicker)
                                case 0: obj[objnum].col0=240; end
                                case 1..10: obj[objnum].col0+=1; END
                                case 11: obj[objnum].col0=143;  end
                                case 12..30: obj[objnum].col0+=1; END
                                case 31..70:
                                    obj[objnum].col0-=1;
                                    if(obj[objnum].col0<128)
                                    obj[objnum].col0=128;
                                    flicker=100;
                                    end
                                    end

                                default:
                                state=dead;
                                hide_player(index,1,0);
                                hide_player(index,1,1);
                                obj[objnum].col0=128;

                                end
                              end
                            flicker+=1;

                            end
                        END


                    END



                     case shot:

                            s_minishell[index].part_id[0].state=out;
                            s_minifuel[index].part_id[0].state=out;

                            vel=0;
                            ang=0;
                        rotate_objxyz(player[index],0,ang,0);
                        angle=obj[player[index]].angley;
                        obj[objnum].posx=x;
                        obj[objnum].posz=y;
                        position_obj(objnum,obj[objnum].posx+rand(-1,1),obj[objnum].posy+rand(-1,1),obj[objnum].posz+rand(-1,1));
                        if(flicker<63)
                            flicker+=1;
                            flickerout(objnum,flicker);

                        else
                            player_id[index].state=dead;
                            obj[objnum].fogme=1;
                            obj[objnum].col0=green;
                        end



                     END


                     CASE boom:
                        sound(snd_exp,256,256);
                        state=exploding;
                        s_minishell[index].part_id[0].state=out;
                        s_minifuel[index].part_id[0].state=out;
                     end


                     case exploding:
                        vel=rand(50,100);
                        dir=rand(0,360000);
                        pitch=rand(5000,40000);
                        rotx=rand(-20000,20000);
                        roty=rand(-20000,20000);
                        rotz=rand(-20000,20000);
                        vely=-get_disty(pitch,vel);
                        velxz=get_distx(pitch,vel);
                        velx=get_distx(dir,velxz);
                        velz=get_distx(dir,velxz);
                        while(obj[objnum].posy>-1)
                            obj[objnum].posx+=velx;
                            obj[objnum].posy+=vely;
                            obj[objnum].posz+=velz;
                            position_obj(objNum,obj[objnum].posx,obj[objnum].posy,obj[objnum].posz);
                            rotate_objxyz(objnum,rotx,roty,0);
                            vely-=1;
                            frame;
                        END
                        hide_player(index,1,0);
                        hide_player(index,1,1);
                        state=dead;
                     END




                     case dead:
                            hide_player(index,1,0);
                            hide_player(index,1,1);
                            obj[objnum].fogme=1;
                            flicker=0;
                            obj[objnum].col0=green;

                     END



                     default:
                     END
                END

            ELSE

                obj[objnum].col0=obj[player[index]].col0;
                obj[objnum].fogme=obj[player[index]].fogme;
                priority=player_id[index].priority-1;
                if(state==running)
                    theta+=15000;
                    swing=sin(theta)*50;
                END
                vel=key(up[index]) or key(dn[index]);

                switch(player_id[index].state)

                    case shot:
                        switch (part)
                            case 1:
                                position_obj(objnum,obj[player[index]].posx,obj[player[index]].posy,obj[player[index]].posz);
                                obj[objnum].angley=obj[player[index]].angley;
                                rotate_objxyz(objnum,0,0,0);
                                move_objy(objnum,24);
                                if(flicker<2)
                                rotate_objxyz(objnum,0,-10000,0);
                                else
                                rotate_objxyz(objnum,0,10000,0);
                                end
                            end
                            //legs
                            case 2:
                                if(flicker<2)
                                dx=16 ; dy=-26; A1=45000;
                                else
                                dx=14 ; dy=-26; A1=35000;
                                end

                                angle=obj[player[index]].angley;
                                px=obj[player[index]].posx+GET_DISTX(ANGLE,dx);
                                py=obj[player[index]].posy+dy;
                                pZ=obj[player[index]].posz+GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);


                            end

                            case 3:
                                if(flicker<2)
                                dx=16 ; dy=-26; A1=-45000;
                                else
                                dx=14 ; dy=-26; A1=-35000;
                                end


                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+dy;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,dx);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);

                            end
                           //arms
                            case 4:

                                if(flicker<2)
                                dx=22 ; dy=20; A1=135000;
                                else
                                dx=22 ; dy=16; A1=125000;
                                end


                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+dy;
                                px=obj[player[index]].posx+GET_DISTX(ANGLE,dx);
                                pZ=obj[player[index]].posz+GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);


                            end

                            case 5:

                                if(flicker<2)
                                dx=22 ; dy=20; A1=-135000;
                                else
                                dx=22 ; dy=16; A1=-125000;
                                end

                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+dy;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,dx);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);

                            end
                            default:
                            end
                        end
                    END



                    case exploding:
                        vel=rand(50,100);
                        dir=rand(0,360000);
                        pitch=rand(5000,40000);
                        rotx=rand(-20000,20000);
                        roty=rand(-20000,20000);
                        rotz=rand(-20000,20000);
                        vely=-get_disty(pitch,vel);
                        velxz=get_distx(pitch,vel);
                        velx=get_distx(dir,velxz);
                        velz=get_distx(dir,velxz);
                        while(obj[objnum].posy>-1)
                            obj[objnum].posx+=velx;
                            obj[objnum].posy+=vely;
                            obj[objnum].posz+=velz;
                            position_obj(objNum,obj[objnum].posx,obj[objnum].posy,obj[objnum].posz);
                            rotate_objxyz(objnum,rotx,roty,0);
                            vely-=1;
                            frame;
                        END
                    end



                    case kamikazi:
                        switch (part)
                            case 1:
                                position_obj(objnum,obj[player[index]].posx,obj[player[index]].posy,obj[player[index]].posz);
                                obj[objnum].angley=obj[player[index]].angley;
                                rotate_objxyz(objnum,0,0,0);
                                move_objxz(objnum,get_distx(obj[objnum].anglex,20));
                                move_objy(objnum,5);
                            end
                            //legs
                            case 2:
                                angle=obj[player[index]].angley;
                                px=obj[player[index]].posx+GET_DISTX(ANGLE,7);
                                py=obj[player[index]].posy-24;
                                pZ=obj[player[index]].posz+GET_DISTy(ANGLE,7);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;

                                obj[objnum].anglex=obj[player[index]].anglex;
                                rotate_objxyz(objnum,0,0,0);
                                move_objxz(objnum,-24);
                                move_objy(objnum,24);
                                rotate_objxyz(objnum,rand(-10000,10000),rand(-10000,10000),0);
                            end

                            case 3:
                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy-24;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,7);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,7);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;

                                obj[objnum].anglex=obj[player[index]].anglex;
                                rotate_objxyz(objnum,0,0,0);
                                move_objxz(objnum,-24);
                                move_objy(objnum,24);
                                rotate_objxyz(objnum,rand(-10000,10000),rand(-10000,10000),0);
                            end
                           //arms
                            case 4:
                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+2;
                                px=obj[player[index]].posx+GET_DISTX(ANGLE,14);
                                pZ=obj[player[index]].posz+GET_DISTy(ANGLE,14);

                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;

                                obj[objnum].anglex=obj[player[index]].anglex;
                                rotate_objxyz(objnum,0,0,0);
                                move_objxz(objnum,14);
                                rotate_objxyz(objnum,key(lf[index])*15000-key(rt[index])*15000,-45000+rand(-15000,15000)-key(rt[index])*45000,0);
                                move_objxz(objnum,7);
                                move_objy(objnum,key(rt[index])*-4);

                            end

                            case 5:
                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+2;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,14);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,14);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;

                                obj[objnum].anglex=obj[player[index]].anglex;
                                rotate_objxyz(objnum,0,0,0);
                                move_objxz(objnum,14);
                                rotate_objxyz(objnum,key(rt[index])*15000-key(lf[index])*15000,45000+rand(-15000,15000)+key(lf[index])*45000,0);
                                move_objxz(objnum,7);
                                move_objy(objnum,key(lf[index])*-4);

                            end

                            default:
                            end
                        END
                    END


                    case hopping:
                        switch (part)
                            case 1:
                                position_obj(objnum,obj[player[index]].posx,obj[player[index]].posy,obj[player[index]].posz);
                                obj[objnum].angley=obj[player[index]].angley;
                                rotate_objxyz(objnum,0,0,0);
                                move_objy(objnum,24);
                                rotate_objxyz(objnum,0,10000,0);
                            end
                            //legs
                            case 2:
                                dx=7 ; dy=-26; A1=000;

                                angle=obj[player[index]].angley;
                                px=obj[player[index]].posx+GET_DISTX(ANGLE,dx);
                                py=obj[player[index]].posy+dy;
                                pZ=obj[player[index]].posz+GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);


                            end

                            case 3:
                                dx=7 ; dy=-26; A1=000;

                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+dy;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,dx);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);

                            end
                           //arms
                            case 4:

                                dx=24 ; dy=8; A1=90000;

                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+dy;
                                px=obj[player[index]].posx+GET_DISTX(ANGLE,dx);
                                pZ=obj[player[index]].posz+GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);


                            end

                            case 5:

                                dx=24 ; dy=8; A1=-90000;

                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+dy;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,dx);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);

                            end

                            default:
                            end
                        end


                    END


                    case onfoot,got_fuel, onfire,got_shell:



                        if(stopnshoot[INDEX]==1)
                            state=shooting;
                            huds_id[index].state=2;
                        else
                            state=running;
                            obj[objnum].anglex=0;
                            huds_id[index].state=1;

                        end

                        switch(part)
                           case 1:
                                position_obj(objnum,obj[player[index]].posx,obj[player[index]].posy,obj[player[index]].posz);

                                    move_objy(objnum,22);

                                    obj[objnum].angley=obj[player[index]].angley;
                                    rotate_objxyz(objnum,0,0,0);

                                    if(state==shooting )

                                        if(key(lf[index]))
                                            aim1+=500;
                                            if(aim1>30000) aim1=30000; END
                                        END
                                        if(key(rt[index]))
                                            aim1-=500;
                                            if(aim1<-30000) aim1=-30000; END
                                        END
                                        obj[objnum].anglex=0;
                                        rotate_objxyz(objnum,aim2,aim1,0);
                                    else
                                        aim1=0;
                                        aim2=0;
                                    end

                            end
                            case 2: //right leg
                                angle=obj[player[index]].angley;
                                px=obj[player[index]].posx+GET_DISTX(ANGLE,7);
                                py=obj[player[index]].posy-24;
                                pZ=obj[player[index]].posz+GET_DISTy(ANGLE,7);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;

                                    if(state==running and vel<>0)
                                        obj[objnum].anglex=swing;
                                        move_objy(objnum,12);
                                        rotate_objxyz(objnum,0,0,0);
                                        move_objxz(objnum,get_disty(swing,-12));
                                        move_objy(objnum,get_distx(swing,-12));
                                        obj[objnum].anglez=0;
                                    ELSE
                                        obj[objnum].anglex=0;
                                        rotate_objxyz(objnum,0,0,0);
                                    END
                            end
                            case 3:
                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy-24;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,7);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,7);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;

                                    if(state==running and vel<>0)
                                        obj[objnum].anglex=-swing;
                                        move_objy(objnum,12);
                                        rotate_objxyz(objnum,0,0,0);
                                        move_objxz(objnum,get_disty(-swing,-12));
                                        move_objy(objnum,get_distx(-swing,-12));
                                    ELSE
                                        obj[objnum].anglex=0;
                                        rotate_objxyz(objnum,0,0,0);
                                    END
                            end

                            case 4:  //right arm
                                if(player_id[index].state<>onfire)

                                    angle=obj[player[index]].angley;
                                    py=obj[player[index]].posy+2;
                                    px=obj[player[index]].posx+GET_DISTX(ANGLE,14);
                                    pZ=obj[player[index]].posz+GET_DISTy(ANGLE,14);


                                    position_obj(objnum,px,py,pz);
                                    obj[objnum].angley=obj[player[index]].angley;

                                    switch (state)
                                     case shooting:
                                        obj[objnum].anglex=90000;
                                        move_objy(objnum,5);
                                        move_objxz(objnum,10);


                                        rotx+=key(up[index])*300;
                                        rotx-=key(dn[index])*300;

                                        obj[objnum].angley=obj[body[index].head].angley;
                                        obj[objnum].anglex+=obj[body[index].head].anglex+rotx;
                                        angle=obj[objnum].angley;

                                        laser(index,objnum);
                                        if(key(fire[index]))
                                            if(fired==0)
                                                if(score.bullets[index]>0)
                                                    bullet(index,objnum);
                                                    score.bullets[index]-=1;
                                                    move_objxz(objnum,-5);
                                                else
                                                  reload(objnum,index,priority-1);
                                                end
                                                fired=1;

                                            end
                                        else
                                            fired=0;
                                        END



                                        rotate_objxyz(objnum,0,0,0);

                                     end


                                    case running:
                                        rotx=0;
                                        roty=0;
                                        if(state==running and vel<>0)
                                            obj[objnum].anglex=-swing;
                                            move_objy(objnum,10);
                                            rotate_objxyz(objnum,0,0,0);
                                            move_objxz(objnum,get_disty(-swing,-12));
                                            move_objy(objnum,get_distx(-swing,-12));
                                            ELSE
                                                obj[objnum].anglex=0;
                                                rotate_objxyz(objnum,0,0,0);

                                        END
                                        if(key(fire[index]))
                                            if(player_id[index].state==got_shell)
                                                player_id[index].state=kamikazi;
                                            else
                                                if(player_id[index].state==got_fuel)
                                                    player_id[index].state=onfoot;
                                                    oilpatch(player_id[index].x,player_id[index].y);
                                                END
                                            END
                                        END
                                    END
                                    default:
                                    end
                                   end
                                else

                                    if(flicker<2)
                                        dx=22 ; dy=20; A1=135000;
                                    else
                                        dx=22 ; dy=16; A1=100000;
                                    end

                                    angle=obj[player[index]].angley;
                                    py=obj[player[index]].posy+dy;
                                    px=obj[player[index]].posx+GET_DISTX(ANGLE+rand(-30000,30000),dx);
                                    pZ=obj[player[index]].posz+GET_DISTy(ANGLE+rand(-30000,30000),dx);
                                    position_obj(objnum,px,py,pz);
                                    obj[objnum].angley=obj[player[index]].angley;
                                    obj[objnum].anglez=A1;
                                    rotate_objzyx(objnum,0,0,0);


                                END

                            end
                            case 5:   //left arm
                               if(player_id[index].state<>onfire)
                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+2;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE,14);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE,14);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;


                                    if(state==running and vel<>0)
                                        obj[objnum].anglex=swing;
                                        move_objy(objnum,10);
                                        rotate_objxyz(objnum,0,0,0);
                                        move_objxz(objnum,get_disty(swing,-12));
                                        move_objy(objnum,get_distx(swing,-12));
                                    ELSE
                                        obj[objnum].anglex=0;
                                        rotate_objxyz(objnum,0,0,0);
                                    END
                               else
                                if(flicker<2)
                                dx=22 ; dy=20; A1=-135000;
                                else
                                dx=22 ; dy=16; A1=-100000;
                                end

                                angle=obj[player[index]].angley;
                                py=obj[player[index]].posy+dy;
                                px=obj[player[index]].posx-GET_DISTX(ANGLE+rand(-30000,30000),dx);
                                pZ=obj[player[index]].posz-GET_DISTy(ANGLE+rand(-30000,30000),dx);
                                position_obj(objnum,px,py,pz);
                                obj[objnum].angley=obj[player[index]].angley;
                                obj[objnum].anglez=A1;
                                rotate_objzyx(objnum,0,0,0);

                               end
                            end
                            default: end
                        end
                    END
                    case dead:
                            obj[objnum].col0=green;
                            flicker=0;

                    end
                    default:
                    END
                 END
             End
        FRAME;
    END
END

//--------------------------------------------------------------------------------


PROCESS plane(objNum,verts,edges,faces,x0,h,z0,ang,col)
BEGIN
    position_obj(objNum,x0,h,z0);
    renderme=draw_objf(objNum,1,1);
    obj[objnum].drawme=1;

    LOOP
        FRAME;
    END
END

//--------------------------------------------------------------------------------


process make_mounts()

private
d=0;
dist=100000;
ang; h;
l_cont=253;
graph0=3;
gotdot;
xh=200;
g;
points=0;
lines=-1;
map;
begin
d=0;
c=0;
g=graph0;
        from map=0 to 1;
            g=graph0+map;
            d=0;
            loop
                d+=1;
                get_point(0,g,d,&ang,&h);
                if(ang==0 and h==0)
                    break;
                else
                    c+=1;
                    m_dot[c].ang=(ang+600-1200*map)*150;
                    m_dot[c].h=(63-h)*xh;
                    m_dot[c].cont=map_get_pixel(0,g,ang,h);
                    points+=1;
                end
            end
        end


        d=1;
        for(c=1; c<=200; c+=1)

        m_line[c].x[0]=get_disty(m_dot[d].ang,dist);
        m_line[c].z[0]=get_distx(m_dot[d].ang,dist);
        m_line[c].y[0]=m_dot[d].h;

        d+=1;
        m_line[c].x[1]=get_disty(m_dot[d].ang,dist);
        m_line[c].z[1]=get_distx(m_dot[d].ang,dist);
        m_line[c].y[1]=m_dot[d].h;

        lines+=1;
            if(m_dot[d].cont<>l_cont)
                d+=1;
               if(d>points) break; end
            end

        end

  mounts(lines,points);
end

PROCESS mounts(lines,points)
private
x1; y1; z1;x0; y0; z0;
k;
BEGIN
    LOOP
          write_int(0,600,100,0,&lines);
          write_int(0,600,110,0,&points);

         for(c=1; c<=lines; c+=1)
          x0=m_line[c].x[0];
          y0=m_line[c].y[0];
          z0=m_line[c].z[0];
          x1=m_line[c].x[1];
          y1=m_line[c].y[1];
          z1=m_line[c].z[1];
          draw_3dline(x0,y0,z0,x1,y1,z1,1,1,green0+30,green0,0);
         end
        FRAME:
    END
END

//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
PROCESS camera_control();
private
    dis[1]; spd; dir; cnt[1]; flash; overlay; ht[1];
BEGIN
    priority=-1002;
    z=draw_z-1000;
    flash=new_map(scr_w,scr_h/2,scr_w/2,scr_h/4,63);
    overlay=new_map(scr_w,scr_h/2,scr_w/2,scr_h/4,64);
    frame;
    LOOP
            for(c=0; c<=1; c+=1)
                switch(player_id[c].state)
                    case action,show:
                        cnt[c]=0;
                        dis[c]= 100;
                        spd=0;
                        ht[c]=20;
                        cam[c].angle=-obj[c].angley-turret_id[c].angle;
                        cam[c].posX= obj[turret[c]].vertex[0].x-get_Disty(obj[turret[c]].angley,dis);
                        cam[c].posY= obj[turret[c]].vertex[0].y+ht[c];
                        cam[c].posZ= obj[turret[c]].vertex[0].z+get_Distx(obj[turret[c]].angley,dis);
                    END
                    case exploding:
                            spd=50;
                            cam[c].posX+=get_disty(cam[c].angle,spd);
                            cam[c].posY+=spd/10;
                            cam[c].posZ+=get_distx(cam[c].angle,spd);


                        end

                    case hopping;
                            if(dis[c]<640)
                                dis[c]+=50;
                                ht[c]+=10;
                            END
                            cam[c].angle=-obj[tank[c]].angley;
                            cam[c].posX= obj[tank[c]].posx+get_disty(cam[c].angle,dis[c]+500);
                            cam[c].posY= obj[tank[c]].posy+ht[c]+50;
                            cam[c].posZ= obj[tank[c]].posz+get_distx(cam[c].angle,dis[c]+500);

                    END

                    case onfoot,got_fuel,got_shell,kamikazi,boom:
                            if(body[c].arm_r_id.state==shooting)

                                if(dis[c]>250)
                                    dis[c]-=25;
                                END
                            ELSE
                                if(dis[c]<500)
                                    dis[c]+=25;
                                END
                            END
                            spd=0;
                            ht[c]=50;
                            cam[c].angle=-obj[body[c].head].angley;
                            cam[c].posX= obj[player[c]].posx+get_disty(cam[c].angle,dis[c]);
                            cam[c].posY= obj[player[c]].posy+ht[c];
                            cam[c].posZ= obj[player[c]].posz+get_distx(cam[c].angle,dis[c]);
                    END

                    default;
                    end
                end
            end
        for(c=0; c<=1; c+=1)
            cam[c].sine=sin(cam[c].angle);
            cam[c].cosine=cos(cam[c].angle);
        END
        FRAME;
    END
END
//--------------------------------------------------------------------------------

PROCESS build_objectf(obj_count,verts,edges,faces,col);
PRIVATE
    i;
BEGIN
    obj[obj_count].fogme=1;
    obj[obj_count].col0=col;
    obj[obj_count].vertex_count=verts;
    for(i=0; i<=verts; i+=1)
        obj[obj_count].vertex[i].x=tmp_vertex[i].x;
        obj[obj_count].vertex[i].y=tmp_vertex[i].y;
        obj[obj_count].vertex[i].z=tmp_vertex[i].z;
        obj[obj_count].vertex[i].xl=tmp_vertex[i].x;
        obj[obj_count].vertex[i].yl=tmp_vertex[i].y;
        obj[obj_count].vertex[i].zl=tmp_vertex[i].z;
    END
    obj[obj_count].edge_count=edges;
    for(i=1; i<=edges; i+=1)
        obj[obj_count].edge[i].v0=tmp_edge[i].v0;
        obj[obj_count].edge[i].v1=tmp_edge[i].v1;
        obj[obj_count].edge[i].col=0;
    END
    obj[obj_count].face_count=faces;
    for(i=1; i<=faces; i+=1)
        obj[obj_count].face[i].e[0]=tmp_face[i].e[0];
        obj[obj_count].face[i].e[1]=tmp_face[i].e[1];
        obj[obj_count].face[i].e[2]=tmp_face[i].e[2];
        obj[obj_count].face[i].e[3]=tmp_face[i].e[3];
        obj[obj_count].face[i].e[4]=tmp_face[i].e[4];
    END
    FRAME;
END

//____DRAW 3DLINE___DRAW3D LINE_________________________

PROCESS draw_3dLine(x0,y0,z0,x1,y1,z1,cam0,cam1,col,col0,fadeout)
PRIVATE
    k; i; DS; px[1]; py[1]; pz[1]; draw_me[1]; colfade[1];  dcol[1];
    sx[1]; sy[1]; tmp;

    struct cv[1]
        x,y,z,
    END;
BEGIN

    line_3d_count+=1;

    px[0]=x0; py[0]=y0; pz[0]=z0;
    px[1]=x1; py[1]=y1; pz[1]=z1;
    priority=-1001;
    draw_me[0]=cam0;
    draw_me[1]=cam1;
    for (k=0; k<=1; k+=1)
        DS=cam[k].depth;
        //draw_me[k]=1;
        FOR(i=0; i<=1; i+=1)
            colfade[k]=0;
            cv[i].x=px[i]-cam[k].posX;
            cv[i].y=py[i]-cam[k].posy;
            cv[i].Z=pz[i]-cam[k].posZ;
            tmp=(cos(cam[k].angle)*cv[i].x+sin(cam[k].angle)*cv[i].z)/1000;
            cv[i].z=(cos(cam[k].angle)*cv[i].z-sin(cam[k].angle)*cv[i].X)/1000;
            cv[i].x=tmp;
            if(cv[i].z>=0)
                draw_me[k]=0;
            END
        END
        if (fadeout)
            colfade[k]=-(cv[1].z+cv[0].z)/512;
            if(colfade[k]>=col-col0)
                draw_me[k]=0;
            END
        END


        if( draw_me[k]==1)
            FOR(i=0; i<=1; i+=1)
                sx[i]=cam[k].cx-cv[i].x*DS/cv[i].z;
                sy[i]=cam[k].cy+cv[i].y*DS/cv[i].z;
            END
            dcol[k]=col-colfade[k];
            draw(1,dcol[k],7,k+1,sx[0],sy[0],sx[1],sy[1]);
        END
    END
    FRAME;
END

//--------------------------------------------------------------------------------
process draw_objf(n,c0,c1)
PRIVATE
    i;
    k;
    ds;
    colfade;
    normy; normx; normz;
    sightx; sighty; sightz;
    facing;
    p1x,p1y,p1z,p0x,p0y,p0z;
    verts; edges; faces;
    cosine; sine;
    incam[1];
    tmp;
    col;
    col0;
    col1;
    dist;
    ang;

    struct cv
        x;
        y;
        z;
    END
BEGIN
    faces=obj[n].face_count;
    edges=obj[n].edge_count;
    verts=obj[n].vertex_count;
    incam[0]=c0;
    incam[1]=c1;
    priority=-1000;
    LOOP
        draw_obj_count+=1;
        if(FACES==0)
            break;
        end

        for (k=0; k<=1; k+=1)
            if(obj[n].invisible[k]==1)
                continue;
            end
            if(incam[k]==1)


                dist=fget_dist(obj[n].posx,obj[n].posz,cam[k].posx,cam[k].posz)/200;
                ang=fget_angle(cam[k].posx,cam[k].posz,obj[n].posx,obj[n].posz)+ cam[k].angle;
                ang=(ang+360000) mod 360000;
                if(ang>10000 and ang<170000)
                    viewtrans_obj+=1;

                else
                    continue;
                END

                sine=cam[k].sine;
                cosine=cam[k].cosine;

                DS=cam[k].depth;

                FOR(i=0; i<=verts; i+=1)
                    cv.x=obj[n].vertex[i].x-cam[k].posX;
                    cv.y=obj[n].vertex[i].y-cam[k].posy;
                    cv.Z=obj[n].vertex[i].z-cam[k].posZ;


                        tmp=(cosine*cv.x+sine*cv.z)/1000;
                        cv.z=(cosine*cv.z-sine*cv.x)/1000;
                        cv.x=tmp;

                    if(cv.z==0)
                        cv.z=1;
                    END
                    obj[n].vertex[i].sx[k]=cam[k].cx-cv.x*DS/cv.z;
                    obj[n].vertex[i].sy[k]=cam[k].cy+cv.y*DS/cv.z;
                    obj[n].vertex[i].sz[k]=cv.z;
                END

                for(c=1; c<=edges; c+=1)
                    obj[n].edge[c].draw_me=0;
                END
                for(c=1; c<=faces; c+=1)
                    if(obj[n].vertex[obj[n].edge[c].v0].sz[k]<clip and obj[n].vertex[obj[n].edge[c].v1].sz[k]<clip)
                        p1x=    obj[n].vertex[obj[n].edge[obj[n].face[c].e[0]].v1].x;
                        p1y=    obj[n].vertex[obj[n].edge[obj[n].face[c].e[0]].v1].y;
                        p1z=    obj[n].vertex[obj[n].edge[obj[n].face[c].e[0]].v1].z;
                        p0x=    obj[n].vertex[obj[n].edge[obj[n].face[c].e[0]].v0].x;
                        p0y=    obj[n].vertex[obj[n].edge[obj[n].face[c].e[0]].v0].y;
                        p0z=    obj[n].vertex[obj[n].edge[obj[n].face[c].e[0]].v0].z;
                        normx=p1x-p0x;
                        normy=p1y-p0y;
                        normz=p1z-p0z;
                        sightx =cam[k].posx-p1x;
                        sighty =cam[k].posy-p1y;
                        sightz =cam[k].posz-p1z;
                        facing=(normx*sightx+normy*sighty+normz*sightz);
                        IF(facing>0)
                            obj[n].edge[obj[n].face[c].e[1]].draw_me=1;
                            obj[n].edge[obj[n].face[c].e[2]].draw_me=1;
                            obj[n].edge[obj[n].face[c].e[3]].draw_me=1;
                            obj[n].edge[obj[n].face[c].e[4]].draw_me=1;
                        ELSE
                            for(i=1; i<=4; i+=1)
                                if(obj[n].edge[obj[n].face[c].e[i]].draw_me==0)
                                    obj[n].edge[obj[n].face[c].e[i]].draw_me=2;
                                END
                            END
                        END
                    END
                END
                for(c=1; c<=edges; c+=1)

                    if(obj[n].edge[c].draw_me<>0)
                    if(obj[n].vertex[obj[n].edge[c].v0].sz[k]<clip and obj[n].vertex[obj[n].edge[c].v1].sz[k]<clip)

                       // if(obj[n].edge[c].col<>0)
                       //     col=obj[n].edge[c].col;
                       // else
                            col=obj[n].col0;
                       // END
                          col0=col-SHADERANGE;
                          col1=col;

                        if(obj[n].edge[c].draw_me==2)
                            col=col0+(col-col0)/2;
                        END


                        IF(obj[n].fogme==1)
                            colfade=-obj[n].vertex[obj[n].edge[c].v0].sz[k]/(cam[k].fog);

                            if(colfade<0)
                                colfade=0;
                            END
                            Col-=colfade/obj[n].edge[c].draw_me;
                              col+=obj[n].light_col;


                        ELSE
                            col=col1;
                            colfade=0;
                           // if(cam[k].posy>1000)
                           //     col=-1;
                           // END
                        END


                       if(obj[n].scint>0)
                        col+=rand(-obj[n].scint,obj[n].scint);
                       end
                        if(Col<=col0)
                            col=col0;
                        ELSE
                            if(col>col1)
                                col=col1;
                            END
                            draw(1,col,10,k+1,
                                obj[n].vertex[obj[n].edge[c].v0].sx[k],
                                obj[n].vertex[obj[n].edge[c].v0].sy[k],
                                obj[n].vertex[obj[n].edge[c].v1].sx[k],
                                obj[n].vertex[obj[n].edge[c].v1].sy[k]);

                        END
                    END
                    END
                END
            END
        END
        FRAME;
    END
END

//----------------------------------------------------------------------------------------
process draw_perimeter(index)
private
    x1;y1; x2; y2; ang;
    ang0;

begin

    loop
    for(c=0; c<36; c+=1)
        x1=get_distx(c*10000,15000);
        y1=get_disty(c*10000,15000);
        x2=get_distx((c+1)*10000,15000);
        y2=get_disty((c+1)*10000,15000);

        //dist=fget_dist((x1+x2)/2,(y1+y2)/2,cam[index].posx,cam[index].posz);
        ang=fget_angle(cam[index].posx,cam[index].posz,x1,y1)+cam[index].angle;
        ang=(ang+360000) mod 360000;
        ang0=fget_angle(cam[index].posx,cam[index].posz,x2,y2)+cam[index].angle;
        ang0=(ang0+360000) mod 360000;


        if((ang>60000 and ang<120000) or (ang0>60000 and ang0<120000))
            draw_3dline(x2,0,y2,x1,0,y1,1-index,index,green,64,1);
            draw_3dline(x1,0,y1,x1,200,y1,1-index,index,green,64,1);
        END

    end
    frame;
    end
end



//--------------------------------------------------------------------------------

PROCESS radar_draw_perimeter(index,x,y,r);
private
    x1;y1;  ang; dist;  rx; ry;
BEGIN


    for(c=0; c<36; c+=1)

        x1=get_distx(c*10000,15000);
        y1=get_disty(c*10000,15000);

        dist=fget_dist(x1,y1,cam[index].posx,cam[index].posz)/200;
        if(dist<r)
            ang=fget_angle(obj[tank[index]].posx,obj[tank[index]].posz,x1,y1)- obj[turret[index]].angley;
            rx=get_distx(ang,dist);
            ry=get_disty(ang,dist);
            draw(1,80,15,0,x+rx,y+ry,x+rx+1,y+ry+1);
        END
    END
    frame;
END
//--------------------------------------------------------------------------------

PROCESS radar(index,x0,y0,r0)
private
    n;  i;   j; k; l;  m; o;  r;
    col; ang; ang2; dist; rx; ry; ang1;
list[2];
BEGIN
x=x0; y=y0; r=r0;
    list[0]=1-index;
    list[1]=obj_pwrfuel[0];
    list[2]=obj_pwrshell[0];
    LOOP
        switch(father.state)
            case 0:
                x=x0; y=y0; r=r0;
                angle=((angle-6000) +360000) mod 360000;
                radar_draw_perimeter(index,x,y,r);
                for(i=0; i<=2; i+=1)
                    n=list[i];
                    if( obj[n].inradar==1)
                        dist=fget_dist(obj[n].vertex[0].x,obj[n].vertex[0].z,obj[index].vertex[0].x,obj[index].vertex[0].z)/200;
                        if(dist<r)
                            ang=fget_angle(obj[index].vertex[0].x,obj[index].vertex[0].z,obj[n].vertex[0].x,obj[n].vertex[0].z)-obj[turret[index]].angley;
                            rx=get_distx(ang,dist);
                            ry=get_disty(ang,dist);
                            ang2=((angle-fget_angle(0,0,rx,ry))+360000) mod 360000;
                            ang2=ang2/6000;
                            blip(n,x+rx,y+ry,obj[n].col0-60+ang2);
                        END
                    END
                END
                draw(1,32,15,0,x,y,x+get_distx(angle,r),y+get_disty(Angle,r));
                draw(1,32,15,0,x,y,
                     x+get_distx(120000,r),
                     y+get_disty(120000,r));
                draw(1,32,15,0,x,y,
                     x+get_distx(60000,r),
                     y+get_disty(60000,r));

                col=green;
                draw(1,col,15,0,
                     x+get_distx(obj[turret[index]].angley-obj[index].angley+45000,10),
                     y-get_disty(obj[turret[index]].Angley-obj[index].angley+45000,10),
                     x-get_distx(obj[turret[index]].angley-obj[index].angley-45000,10),
                     y+get_disty(obj[turret[index]].Angley-obj[index].angley-45000,10));
                draw(1,col,15,0,
                     x+get_distx(obj[turret[index]].angley-obj[index].angley+45000,10),
                     y-get_disty(obj[turret[index]].Angley-obj[index].angley+45000,10),
                     x-get_disty(obj[turret[index]].angley-obj[index].angley,10),
                     y-get_distx(obj[turret[index]].Angley-obj[index].angley,10));
                draw(1,col,15,0,
                     x-get_distx(obj[turret[index]].angley-obj[index].angley-45000,10),
                     y+get_disty(obj[turret[index]].Angley-obj[index].angley-45000,10),
                     x-get_disty(obj[turret[index]].angley-obj[index].angley,10),
                     y-get_distx(obj[turret[index]].Angley-obj[index].angley,10));
                draw(1,red,15,0,//x,y,
                     x-get_distx(93000+obj[turret[index]].angley,r-10),
                     y+get_disty(93000+obj[turret[index]].Angley,r-10),
                     x-get_distx(93000+obj[turret[index]].angley,r),
                     y+get_disty(93000+obj[turret[index]].Angley,r));
                draw(1,red,15,0,//x,y,
                     x-get_distx(87000+obj[turret[index]].angley,r-10),
                     y+get_disty(87000+obj[turret[index]].Angley,r-10),
                     x-get_distx(87000+obj[turret[index]].angley,r),
                     y+get_disty(87000+obj[turret[index]].Angley,r));
                draw(1,red,15,0,//x,y,
                     x-get_distx(93000+obj[turret[index]].angley,r-10),
                     y+get_disty(93000+obj[turret[index]].Angley,r-10),
                     x-get_distx(87000+obj[turret[index]].angley,r),
                     y+get_disty(87000+obj[turret[index]].Angley,r));

                col=32;
                draw(4,col,15,0,x-r,y-r,x+r,y+r);

            end
            case 1:
                r=30;
                x=scr_w-r-2; y=scr_h-cam[index]*scr_cy-r-2;
                col=32;
                c=r/5;
                ang1=obj[player[index]].angley;
                draw(4,col,15,0,x-r,y-r,x+r,y+r);
                draw(1,red,15,0,
                     x-get_disty(ang1+90000,c),
                     y-get_distx(ang1+90000,c),
                     x-get_disty(ang1,r-c),
                     y-get_distx(ang1,r-c));
                draw(1,red,15,0,
                     x-get_disty(ang1-90000,c),
                     y-get_distx(ang1-90000,c),
                     x-get_disty(ang1,r-c),
                     y-get_distx(ang1,r-c));

                draw(1,cyan,15,0,
                     x-get_disty(ang1+90000,c),
                     y-get_distx(ang1+90000,c),
                     x-get_disty(ang1+180000,r-c),
                     y-get_distx(ang1+180000,r-c));
                draw(1,cyan,15,0,
                     x-get_disty(ang1-90000,c),
                     y-get_distx(ang1-90000,c),
                     x-get_disty(ang1+180000,r-c),
                     y-get_distx(ang1+180000,r-c));

                /*
                draw(1,cyan,15,0,//x,y,
                     x-get_disty(87000+ang1,20),
                     y-get_distx(87000+ang1,20),
                     x-get_distx(87000+ang1,r-20),
                     y+get_disty(87000+ang1,r-20));
                draw(1,red,15,0,//x,y,
                     x-get_distx(93000+ang1,10),
                     y+get_disty(93000+ang1,10),
                     x-get_distx(87000+ang1,r),
                     y+get_disty(87000+ang1,r));
                */
            end
            default:
            end
        end

        FRAME;
    end
END

//--------------------------------------------------------------------------------
PROCESS blip(n,x,y,col0)
    PRIVATE
        r=1; life=64;
    BEGIN
        while(life>0)
            if(col0<0)
                col0=0;
            END
            draw(3,col0,15,0,x-r,y-r,x+r,y+r);
            life-=32;
        FRAME;
    END
END
//--------------------------------------------------------------------------------
