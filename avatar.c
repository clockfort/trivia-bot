#include <SDL.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <math.h>
#include <stdlib.h>

void bail(const char *msg)
{
    fprintf(stderr, "error: %s\nexiting...\n", msg);
    exit(1);
}

void set_vsync(int enable)
{
#if SDL_VERSION_ATLEAST(1, 3, 0)
    SDL_GL_SetSwapInterval(enable);
#else
    SDL_GL_SetAttribute(SDL_GL_SWAP_CONTROL, enable);
#endif
}

int main(int argc, char *argv[])
{
    const int screen_x = 1600, screen_y = 1200;
    int running = 1, ticks_prev, ticks_curr;
    float delta, cam_th = 0.0f, cam_x, cam_z, planet_th = 0.0f, sat_th = 0.0f;
    float lt1_diffuse[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    float lt2_diffuse[] = { 0.0f, 1.0f, 0.0f, 1.0f };
    float green_diffuse[] = { 0.0f, 1.0f, 0.0f, 1.0f };
    float red_diffuse[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    float ballColor[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    float lt_origin[] = { 0.0f, 0.0f, 0.0f, 1.0f };
    float myRed,myGreen;
    myRed = myGreen = 0.0f;
    SDL_Surface *surface;
    SDL_Event event;
    GLUquadric *quadric;
    int mySpeed = 3;

    // initialize SDL

    if (0 > SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER))
        bail("failed to initialize SDL");

    surface = SDL_SetVideoMode(screen_x, screen_y, 32, SDL_OPENGL);
    if (!surface)
        bail("failed to set video mode");

    set_vsync(1);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
    SDL_WM_SetCaption("Avatar GUI Test", 0);

    ticks_prev = SDL_GetTicks();

    // initialize GL

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHT0);
    glEnable(GL_LIGHT1);
    glEnable(GL_LIGHT2);
    glEnable(GL_LIGHT3);
    glEnable(GL_LIGHT4);
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);

    glDepthFunc(GL_LESS);
    glShadeModel(GL_SMOOTH);

    glClearColor(0, 0, 0, 1);
    glClearDepth(1);
    glViewport(0, 0, screen_x, screen_y);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60.0f, (float)screen_x / screen_y, 0.1f, 100.0f);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    quadric = gluNewQuadric();
    gluQuadricNormals(quadric, GLU_SMOOTH);
    gluQuadricTexture(quadric, GL_FALSE);

    // render loop

    while (running) {

        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_KEYDOWN:
                if (SDLK_ESCAPE == event.key.keysym.sym)
                    running = 0;
		if (SDLK_F1 == event.key.keysym.sym){
			myRed = 0.0f;
			myGreen = 1.0f;
			ballColor[0] = myRed;
			ballColor[1] = myGreen;
		}
		if (SDLK_F2 == event.key.keysym.sym){
			myRed = 1.0f;
			myGreen = 0.0f;
			ballColor[0] = myRed;
			ballColor[1] = myGreen;
		}
		if (SDLK_F3 == event.key.keysym.sym){
			mySpeed--;
		}
		if (SDLK_F4 == event.key.keysym.sym){
			mySpeed++;
		}
                break;
            case SDL_QUIT:
                running = 0;
                break;
            }
        }

        // calculate the time delta between this frame and the previous

        ticks_curr = SDL_GetTicks();
        delta = (ticks_curr - ticks_prev) / 1000.0f;
        ticks_prev = ticks_curr;

        //cam_th += delta * 0.1f;
        sat_th += mySpeed * delta * (180.0f / M_PI);
        planet_th += delta * (180.0f / M_PI);

        cam_x =  0.1f * cos(cam_th);
        cam_z =  0.1f * sin(cam_th);

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glLoadIdentity();
        gluLookAt(cam_x, 10, cam_z, 0, 0, 0, 0, 1, 0);

/*        // render the basis vectors

        glBegin(GL_LINES);
            glColor3f(1, 0, 0);
            glVertex3f(0, 0, 0);
            glVertex3f(2, 0, 0);

            glColor3f(0, 1, 0);
            glVertex3f(0, 0, 0);
            glVertex3f(0, 2, 0);
            
            glColor3f(0, 0, 1);
            glVertex3f(0, 0, 0);
            glVertex3f(0, 0, 2);
        glEnd();
*/
        // set the position to the planet's center

        //glRotatef(planet_th, 0, 1, 0);
        //glTranslatef(5, 3 * cos(planet_th * 0.03f), 0);

        // render the first satellite

        glPushMatrix();
        glRotatef(sat_th, 0, 1, 1);
        glTranslatef(2, 0, 0);
        glLightfv(GL_LIGHT1, GL_DIFFUSE, ballColor);
        glLightfv(GL_LIGHT1, GL_POSITION, lt_origin);
        glColor3f(myRed, myGreen, 0);
        gluSphere(quadric, 0.2f, 64, 64);
        glPopMatrix();

        // render the second satellite

        glPushMatrix();
        glRotatef(sat_th, 0, -1, 1);
        glTranslatef(2, 0, 0);
        glLightfv(GL_LIGHT2, GL_DIFFUSE, ballColor);
        glLightfv(GL_LIGHT2, GL_POSITION, lt_origin);
        glColor3f(myRed, myGreen, 0);
        gluSphere(quadric, 0.2f, 64, 64);
        glPopMatrix();


	// render the third satellite
	glPushMatrix();
        glRotatef(sat_th, 0.5, -0.5, 0.5);
        glTranslatef(0, 2, 0);
        glLightfv(GL_LIGHT3, GL_DIFFUSE, ballColor);
        glLightfv(GL_LIGHT3, GL_POSITION, lt_origin);
        glColor3f(myRed, myGreen, 0);
        gluSphere(quadric, 0.2f, 64, 64);
        glPopMatrix();

        // render the fourth satellite
        glPushMatrix();
        glRotatef(sat_th, 2, -0.5, 0.5);
        glTranslatef(0, 2, 0);
        glLightfv(GL_LIGHT4, GL_DIFFUSE, ballColor);
        glLightfv(GL_LIGHT4, GL_POSITION, lt_origin);
        glColor3f(myRed, myGreen, 0);
        gluSphere(quadric, 0.2f, 64, 64);
        glPopMatrix();

        // render the planet around which the satellites rotate

        glEnable(GL_LIGHTING);
        glColor3f(0.3, 0.3, 0.3);
        gluSphere(quadric, 1, 64, 64);
        glDisable(GL_LIGHTING);

        SDL_GL_SwapBuffers();
    }

    return 0;
}

